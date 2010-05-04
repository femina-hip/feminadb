module HelpsHelper
  def render_help_steps(&block)
    content_tag(:ol, :class => 'help', &block)
  end

  def render_help_step(title, &block)
    content_tag(:li, (content_tag(:h3, title) + capture(&block)).html_safe)
  end

  def search_link(search)
    link_to(search, customers_path(:q => search))
  end
end
