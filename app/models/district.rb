class District < ActiveRecord::Base
  belongs_to(:region)

  validates_uniqueness_of :name, :scope => :region_id

  validates_format_of :color, :with => /\A[0-9a-f]{6}\Z/, :message => 'must look like "03af24"'
  validates_uniqueness_of :color

  def color=(value)
    if value.to_s =~ /^#?([0-9a-f]{6})$/i
      value = $1.downcase
    end
    write_attribute(:color, value)
  end
end
