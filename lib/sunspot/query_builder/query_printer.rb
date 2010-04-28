module Sunspot
  module QueryBuilder
    module Printer
      class Walker
        attr_reader(:syntax_tree)
        attr_reader(:output)

        def initialize(syntax_tree)
          @syntax_tree = syntax_tree
          @output = ""
        end

        def process
          process_node(@syntax_tree)
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
          first, rest = node.subnodes.first, node.subnodes[1..-1]
          process_node(first)
          rest.each do |node|
            output << ' AND '
            process_node(node)
          end
        end

        def process_disjunction(node)
          first, rest = node.subnodes.first, node.subnodes[1..-1]
          process_node(first)
          rest.each do |node|
            output << ' OR '
            process_node(node)
          end
        end

        def process_dynamic_field(node)
          dynamic_field, field = node.subnodes
          output << "#{dynamic_field.text_value}:#{field.text_value}"
        end

        def process_field(node)
          output << node.text_value
        end

        def process_comparator(node)
          output << node.text_value
        end

        def process_value(node)
          s = node.text_value
          if s.empty?
            output << '""'
          elsif s =~ /"/
            output << "'#{s}'"
          elsif s =~ /'|\s/
            output << "\"#{s}\""
          else
            output << s
          end
        end

        def process_factor(node)
          if node.not?
            output << '-'
          end
          process_subnodes(node)
        end

        def process_test(node)
          if node.needs_parentheses?
            output << '('
          end
          process_subnodes(node)
          if node.needs_parentheses?
            output << ')'
          end
        end
      end

      def self.print(st)
        walker = Walker.new(st)
        walker.process
        puts walker.output
      end
    end
  end
end
