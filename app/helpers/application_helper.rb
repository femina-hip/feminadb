require 'lib/issue_selector'
require 'lib/customer_type_selector'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Glossary

  def render_loading
    update_page do |page|
      page.show :loading
    end
  end

  def render_pretty_header(title, &block)
    description = capture &block

    render :partial => 'application/pretty_header', :locals => { :title => title, :description => description }
  end

  # Displays a User as a string
  #
  # Normally returns user's login. If passed nil, returns "(unknown)"
  def render_user(user)
    if user
      h user.login
    else
      '(unknown)'
    end
  end
end
