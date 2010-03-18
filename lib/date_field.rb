module DateField
  def date_field(method)
    class_eval <<-EOT
      def #{method}_string
        d = self.#{method}
        d.blank? ? nil : d.strftime('%b %d %Y')
      end

      def #{method}_string=(value)
        d = nil
        begin
          d = Date.parse(value)
        rescue ArgumentError
          # d = nil
        end

        self.#{method} = d
      end
    EOT
  end
end
