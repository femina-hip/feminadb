class District < ActiveRecord::Base
  acts_as_paranoid
  versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  belongs_to :region

  validates_uniqueness_of :name, :scope => :region_id

  validates_format_of :color, :with => /\A[0-9a-f]{6}\Z/,
                      :message => 'must look like "03af24"'
  validates_uniqueness_of :color

  def color=(value)
    if value.to_s =~ /^#?([0-9a-f]{6})$/i
      value = $1.downcase
    end
    write_attribute(:color, value)
  end
end
