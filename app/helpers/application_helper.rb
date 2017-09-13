# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include GlossaryHelper

  def render_pretty_header(title, &block)
    description = capture(&block)

    render(:partial => 'application/pretty_header', :locals => { :title => title, :description => description.html_safe })
  end

  # Displays a User as a string
  #
  # Normally returns user's login. If passed nil, returns "(unknown)"
  def render_user(user)
    if user
      h(user.login)
    else
      '(unknown)'.html_safe
    end
  end

  # refineq('foo', 'council', '') returns 'foo council:""'
  def refine_q(original_q, term, value)
    q = "#{original_q} #{term}:"

    value = value.strip
    if value.empty?
      q << '""'
    elsif value =~ / /
      if value =~ /"/
        q << "'#{value}'"
      else
        q << "\"#{value}\""
      end
    else
      q << value
    end

    q.strip
  end
end
