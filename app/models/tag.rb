class Tag < ActiveRecord::Base
  has_and_belongs_to_many(:customers, dependent: :delete)
  attribute(:light_or_dark, :string)

  def light_or_dark
    rgb = color.sub('#', '').to_i(16)
    r = rgb >> 16
    g = (rgb >> 8) & 0xff
    b = rgb & 0xff
    luma = 0.2126 * r + 0.7152 * g + 0.0722 * b # ITU-R BT.709

    if luma >= 128
      'light'
    else
      'dark'
    end
  end
end
