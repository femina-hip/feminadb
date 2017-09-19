class Tag < ActiveRecord::Base
  has_and_belongs_to_many(:customers, dependent: :delete)

  # We use to_json to pass the tag list through HTML to JavaScript for
  # customer_tags_field
  def attributes
    {
      'id': nil,
      'name': nil,
      'color': nil,
      'light_or_dark': nil
    }
  end

  def light_or_dark
    if Sass::Script::Value::Color.from_hex(color).lightness > 50
      'light'
    else
      'dark'
    end
  end
end
