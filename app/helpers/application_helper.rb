# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include GlossaryHelper
  include Forms::ApplicationHelper

  def render_loading
    update_page do |page|
      page.show :loading
    end
  end

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

  def explanation_ul_for_customer_query(query)
    parser = Sunspot::QueryBuilder::SyntaxParser.new
    tree = parser.parse(query)
    explanation = Sunspot::QueryBuilder::Explainer.build_explanation(tree)
    if explanation == [:all]
      "You asked for all records"
    else
      "#{explanation_ul_step(explanation, :label => 'You asked for all records which have')}".html_safe
    end
  #rescue
  #  content_tag(:p, 'Sorry, a bug in FeminaDB made this break', :class => 'error')
  end

  private

  def explanation_ul_step(explanation, options = {})
    label = options[:label] && "#{options[:label]} " || ''
    if Array === explanation
      if Symbol === explanation.first
        conjunction = case explanation.first
        when :all then 'all of:'
        when :any then 'any of:'
        when :not then 'not:'
        else '???(FeminaDB bug)???:'
        end
        subnodes = explanation[1..-1]
        [
          content_tag(:p, "#{label}#{conjunction}", :class => 'conjunction'),
          content_tag(:ul, subnodes.collect{|e| content_tag(:li, explanation_ul_step(e))}.join.html_safe)
        ].join.html_safe
      else
        explanation_ul_field_query(explanation)
      end
    else
      explanation_ul_query(explanation)
    end
  end

  def explanation_ul_field_query(field_query)
    if ['true', 'false'].include?(field_query.last)
      explanation_ul_boolean(field_query.first, $1 == 'true')
    else
      "#{content_tag(:q, explanation_ul_field(field_query[0..-3]), :class => 'field')} #{explanation_ul_comparator(field_query[-2])} #{content_tag(:q, field_query.last)}".html_safe
    end
  end

  def explanation_ul_comparator(comparator)
    case comparator
    when ':' then 'of'
    when '=' then 'of'
    when '>' then 'greater than'
    when '<' then 'less than'
    when '>=' then 'at least'
    when '<=' then 'at most'
    end
  end

  def explanation_ul_boolean(field, boolean)
    if field =~ /(standing|waiting):(.*)/
      publication = Publication.all.select{|p| p.to_index_key == $2}.first.try(:title) || '???'
      if boolean
        "some #{$1.capitalize} Orders for #{publication}"
      else
        "no #{$1.capitalize} Orders for #{publication}"
      end
    elsif field =~ /has_club/
      boolean && 'with clubs' || 'without clubs'
    else
      "Have #{field} of #{boolean}"
    end
  end

  def explanation_ul_field(field)
    case field
    when /standing/ then 'blah'
    else field
    end
  end

  def explanation_ul_query(query)
    "#{content_tag(:q, query)} anywhere".html_safe
  end
end
