class Club < ActiveRecord::Base
  extend DateField

  versioned
  include SoftDeletable
  acts_as_reportable

  validates_presence_of :customer_id
  validates_uniqueness_of :customer_id,
        :scope => :deleted_at, :if => lambda { |c| c.deleted_at.nil? }
  validates_presence_of :name

  date_field :date_founded

  belongs_to :customer
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by

  def telephones_string
    [ telephone_1, telephone_2 ].collect{|ct| ct.to_s.strip}.select{|ct| not ct.empty?}.join(', ')
  end
end
