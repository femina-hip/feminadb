#module ActionView
#  module Helpers
#    module FormHelper
#      def customer_type_select(object_name, method, options = {}, html_options = {})
#        obj = options[:object] || instance_eval("@#{object_name}")
#
#        options[:selected] ||= obj.send(method)
#        value = options[:selected] || obj.send(method)
#
#        InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_customer_type_select_tag(select_options(value), html_options)
#      end
#
#      private
#        def select_options(selected_value = nil)
#          dict = CustomerType.find(:all, :order => 'category, name').group_by(&:category)
#          categories = dict.keys.sort
#
#          categories.collect do |category|
#            "<optgroup label=\"#{h(category)}\">" + \
#              dict[category].collect do |type|
#                selected = (type.id == selected_value ? ' selected="selected"' : '')
#                key = type.id
#                value = "#{h(type.name)}: #{h(type.description)}"
#                "<option value=\"#{key}\"#{selected}>#{value}</option>"
#              end.join + \
#              '</optgroup>'
#          end
#        end
#    end
#
#    class InstanceTag #:nodoc:
#      include FormOptionsHelper
#
#      def to_customer_type_select_tag(options, html_options)
#        add_default_name_and_id(html_options)
#        content_tag('select', options, html_options)
#      end
#    end
#
#    class FormBuilder
#      def customer_type_select(method, options = {})
#        @template.customer_type_select(@object_name, method,
#                                       options.merge(:object => @object))
#      end
#    end
#  end
#end
