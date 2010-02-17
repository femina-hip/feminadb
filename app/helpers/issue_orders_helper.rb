module IssueOrdersHelper
  def delivery_method_abbr(dm)
    "<abbr title=\"#{h(dm.name)}\">#{h(dm.abbreviation)}</abbr>"
  end
end
