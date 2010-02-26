class Pagination::Renderer < WillPaginate::LinkRenderer
  def to_html
    stuff = []
    stuff << 'Page'
    stuff << page_form
    stuff << 'of %d' % send(:total_pages)

    @template.content_tag(:div, stuff, html_attributes)
  end

  private
    def hidden_inputs
      options = @template.params.dup
      options.delete :page
      options.delete :commit
      options.delete :controller
      options.delete :action
      options.merge(@options[:params]) if @options[:params]

      options.collect{ |k,v| @template.hidden_field_tag k, v }
    end

    def page_form
      @template.content_tag(:form, @template.url_for) do
        @template.content_tag(:div) do
          hidden_inputs + [
            @template.text_field_tag(:page, send(:current_page))
          ]
        end
      end
    end
end
