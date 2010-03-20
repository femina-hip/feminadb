module ReportsHelper
  def format(v)
    return v.name if v.is_a? Region
    return v.name if v.is_a? CustomerType
    return "%0.2f"%v if v.is_a? Float
    return number_with_delimiter(v) if v.is_a? Fixnum
    v.to_s
  end

  # Returns a form input tag based on the given report parameter.
  def html_form_input(p, f)
    if p[:class] == Issue
      f.issue_field(p[:key])
    else
      raise NotImplementedException
    end
  end
end
