module QueryBuilder
  class Searcher
    # Should be two classes: the visitor and the search mutator
    attr_reader(:search, :connective_stack)
    attr_accessor(:dynamic_field, :field, :comparator, :value)

    def initialize(search, tree)
      @search = search
      @connective_stack = [search.send(:dsl).instance_variable_get(:@scope)]
      @search_setup = search.instance_variable_get(:@setup)
      @text_setup = Sunspot::TextFieldSetup.new(@search_setup)
      @tree = tree
    end

    def process
      process_node(@tree)
    end

    private

    def process_node(node)
      method_sym = "process_#{node.type}".to_sym

      if self.respond_to?(method_sym, true)
        self.send(method_sym, node)
      else
        process_subnodes(node)
      end
    end

    def process_subnodes(node)
      node.subnodes.each do |subnode|
        process_node(subnode)
      end
    end

    def process_conjunction(node)
      connective_stack.push(connective_stack.last.add_conjunction)
      process_subnodes(node)
      connective_stack.pop
    end

    def process_disjunction(node)
      connective_stack.push(connective_stack.last.add_disjunction)
      process_subnodes(node)
      connective_stack.pop
    end

    def process_factor(node)
      connective_stack.push(connective_stack.last.add_component(Sunspot::Query::Connective::Conjunction.new(node.not?)))
      process_subnodes(node)
      connective_stack.pop
    end

    def process_filter(node)
      reset_filter
      process_subnodes(node)
      create_search_restriction
    end

    def process_dynamic_field(node)
      dynamic_field, field = node.subnodes
      self.dynamic_field = dynamic_field.text_value
      self.field = field.text_value
    end

    def process_field(node)
      self.field = node.text_value
    end

    def process_comparator(node)
      self.comparator = node.text_value
    end

    def process_value(node)
      self.value = node.value
    end

    def reset_filter
      @dynamic_field = nil
      @field = nil
      @comparator = nil
      @restriction_type = nil
      @value = nil
    end

    def field_instance
      if dynamic_field
        @search_setup.dynamic_field_factory(dynamic_field).field(field)
      elsif (restriction_type != Sunspot::Query::Restriction::EqualTo && restriction_type != Sunspot::Query::Restriction::StartingWith) || value == ''
        @search_setup.field(field)
      else
        ret = begin
          @search_setup.text_fields(field).first
        rescue Sunspot::UnrecognizedFieldError
          nil
        end
        ret ||= @search_setup.field(field)
      end
    end

    def parsed_date_value
      Date.parse(value)
    rescue ArgumentError
      Date.today
    end

    def parsed_value
      if Sunspot::Type::DateType === field_instance.type
        parsed_date_value
      else
        field_instance.cast(value)
      end
    end

    def restriction_type
      @restriction_type ||= begin
        # FIXME Sunspot doesn't handle all restrictions!
        sym = case comparator
        when ':' then :equal_to
        when '=' then :equal_to
        when '>' then :greater_than
        when '<' then :less_than
        when '>=' then :greater_than
        when '<=' then :less_than
        end

        if sym == :equal_to && value =~ /(.*)[\*~]$/
          @value = $1
          Sunspot::Query::Restriction[:starting_with]
        else
          Sunspot::Query::Restriction[sym]
        end
      end
    end

    def create_fulltext_search_restriction
      search.send(:dsl).fulltext(value) # FIXME Doesn't negate/OR/anything!
    end

    def create_search_restriction
      if field
        begin
          fi = field_instance
        rescue Sunspot::UnrecognizedFieldError
          return create_fulltext_search_restriction
        end
        connective_stack.last.add_restriction(false, field_instance, restriction_type, parsed_value)
      else
        create_fulltext_search_restriction
      end
    end
  end
end
