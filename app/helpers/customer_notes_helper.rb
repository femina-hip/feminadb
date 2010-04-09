module CustomerNotesHelper
  def note_column(record)
    "<div class=\"redcloth\">#{textilize(record.note).html_safe}</div>"
  end
end
