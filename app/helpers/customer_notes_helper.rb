module CustomerNotesHelper
  def note_column(record)
    "<div class=\"redcloth\">#{textilize(record.note)}</div>"
  end
end
