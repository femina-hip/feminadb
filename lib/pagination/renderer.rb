class Pagination::Renderer < WillPaginate::LinkRenderer
  def to_html
    inner = "Page #{page_form} of #{send(:total_pages)}".html_safe

    @template.content_tag(:div, inner, html_attributes)
  end

  private

  def hidden_inputs
    options = @template.params.dup
    options.delete :page
    options.delete :commit
    options.delete :controller
    options.delete :action
    options.merge(@options[:params]) if @options[:params]

    options.collect{ |k,v| @template.hidden_field_tag(k, v) }
  end

  def page_form
    stuff = hidden_inputs + [@template.text_field_tag(:page, send(:current_page))]
    inner = stuff.join.html_safe

    @template.content_tag(:form, @template.url_for) do
      @template.content_tag(:div, inner)
    end
  end
end
