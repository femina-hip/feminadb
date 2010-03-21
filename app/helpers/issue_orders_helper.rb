module IssueOrdersHelper
  def delivery_method_abbr(dm)
    content_tag(:abbr, dm.abbreviation, :title => dm.name)
  end
end
