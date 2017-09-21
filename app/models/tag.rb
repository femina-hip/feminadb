class Tag < ActiveRecord::Base
  has_and_belongs_to_many(:customers, dependent: :delete)
  attribute(:light_or_dark, :string)

  def light_or_dark
    if Sass::Script::Value::Color.from_hex(color).lightness > 50
      'light'
    else
      'dark'
    end
  end
end
