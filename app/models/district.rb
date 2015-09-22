class District < ActiveRecord::Base
  include SoftDeletable
  #versioned

  belongs_to(:region)

  validates_uniqueness_of :name, :scope => [ :region_id, :deleted_at ], :if => lambda { |d| d.deleted_at.nil? }

  validates_format_of :color, :with => /\A[0-9a-f]{6}\Z/, :message => 'must look like "03af24"'
  validates_uniqueness_of :color, :scope => :deleted_at, :if => lambda { |d| d.deleted_at.nil? }

  def color=(value)
    if value.to_s =~ /^#?([0-9a-f]{6})$/i
      value = $1.downcase
    end
    write_attribute(:color, value)
  end
end
