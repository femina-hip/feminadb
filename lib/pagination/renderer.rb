class Pagination::Renderer < WillPaginate::LinkRenderer
  protected
    def windowed_paginator
      ret = []
      ret << 'Page'
      ret << page_form
      ret << 'of %d' % total_pages
    end

  private
    def current_page
      @collection.current_page
    end

    def total_pages
      @collection.page_count
    end

    def hidden_inputs
      options = params
      options.delete :page
      options.delete :commit
      options.delete :controller
      options.delete :action
      options.rec_marge!(@options[:params]) if @options[:params]

      options.collect{ |k,v| @template.hidden_field_tag k, v }
    end

    def page_form
      @template.content_tag(:form, @template.url_for) do
        @template.content_tag(:div) do
          hidden_inputs + [
            @template.text_field_tag(:page, current_page)
          ]
        end
      end
    end
end
