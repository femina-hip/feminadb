module Sunspot
  module QueryBuilder
    class Explainer
      def self.build_explanation(tree)
        ret = new.process_node(tree)
        if ret == []
          ret = [:all]
        else
          ret
        end
      end

      def process_node(node)
        method_sym = "process_#{node.type}".to_sym

        if self.respond_to?(method_sym, true)
          self.send(method_sym, node)
        else
          process_subnodes(node)
        end
      end

      private

      def process_subnodes(node)
        if node.subnodes.length == 1
          process_node(node.subnodes.first)
        else
          node.subnodes.collect do |subnode|
            process_node(subnode)
          end
        end
      end

      def process_conjunction(node)
        if node.subnodes.length == 1
          process_subnodes(node)
        else
          [ :all ] + process_subnodes(node)
        end
      end

      def process_disjunction(node)
        if node.subnodes.length == 1
          process_subnodes(node)
        else
          [ :any ] + process_subnodes(node)
        end
      end

      def process_dynamic_field(node)
          dynamic_field, field = node.subnodes
        "#{dynamic_field.text_value}:#{field.text_value}"
      end

      def process_field(node)
        node.text_value
      end

      def process_comparator(node)
        node.text_value
      end

      def process_value(node)
        node.text_value
      end

      def process_factor(node)
        if node.not?
          [ :not, process_subnodes(node) ]
        else
          process_subnodes(node)
        end
      end

      def process_test(node)
        process_subnodes(node)
      end
    end
  end
end
