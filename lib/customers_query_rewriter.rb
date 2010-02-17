module CustomersQueryRewriter
  # Part of Feature #11

  def customers_query(q)
    r = q ? q.dup : ''
    r.gsub! /region:/, 'region_name:'
    r.gsub! /delivery_method:/, 'delivery_method_abbreviation:'
    r.gsub! /type:/, 'type_name:'
    r.gsub! /via:/, 'deliver_via:'
    r.gsub! /po:/, 'po_box:'
    r.gsub! /club:/, 'club_yes_no:'
    r.gsub! /category:/, 'type_category:'
    r.gsub!(/tag:"(.*?)"/){ |m| "TAG_#{Tags.normalize_name($1)}" }
    r = '*' if r.strip.empty?
    r
  end
end
