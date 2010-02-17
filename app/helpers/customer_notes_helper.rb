module CustomerNotesHelper
  def note_column(record)
    "<div class=\"redcloth\">#{RedCloth.new(record.note).to_html}</div>"
  end
end
