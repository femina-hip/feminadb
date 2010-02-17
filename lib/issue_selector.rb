module ActionView
  module Helpers
    module FormHelper
      def issue_select(object_name, method, options = {})
        obj = options[:object] || instance_eval("@#{object_name}")
        issue = Issue.find_or_initialize_by_id(obj.send(method))

        options[:controller] ||= 'issues_select'
        record_select_field "#{object_name}[#{method}]", issue, options
      end
    end

    module FormTagHelper
      def issue_select_tag(name, object = nil, options = {})
        options[:controller] ||= 'issues_select'
        options[:id] ||= "#{name}_#{name.object_id.to_s.tr('-', '_')}"
        record_select_field name, object, options
      end
    end

    class FormBuilder
      def issue_select(method, options = {})
        @template.issue_select(@object_name, method,
                               options.merge(:object => @object))
      end
    end
  end
end
