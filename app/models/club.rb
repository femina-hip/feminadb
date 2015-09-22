class Club < ActiveRecord::Base
  extend DateField

  include SoftDeletable
  #versioned

  validates_presence_of :customer_id
  validates_uniqueness_of :customer_id,
        :scope => :deleted_at, :if => lambda { |c| c.deleted_at.nil? }
  validates_presence_of :name

  date_field :date_founded

  belongs_to(:customer)
  after_save { |club| club.customer.try(:index) }

  def title; name; end

  def telephones_string
    [ telephone_1, telephone_2 ].collect{|ct| ct.to_s.strip}.select{|ct| not ct.empty?}.join(', ')
  end

  def customer_delivery_method
    customer.try(:delivery_method)
  end

  def customer_region
    customer.try(:region)
  end

  def customer_type
    customer.try(:type)
  end

  comma do
    customer_region(:name => 'Region')
    customer(:district => 'District')
    name('Name')
    email('Email')
    address('Address')
    telephone_1('Tel.')
    telephone_2('Tel. (2)')
    num_members('# Members')
    date_founded('Date founded')
    motto('Motto')
    objective('Objective')
    eligibility('Eligibility')
    work_plan('Work Plan')
    patron('Patron')
    intended_duty('Intended Duty')
    founding_motivation('Founding Motivation')
    cooperation_ideas('Cooperation Ideas')
    customer(:name => 'Customer Name')
    customer_type(:name => 'Cust. Type')
    customer_type(:description => 'Customer Type (long)')
    customer_delivery_method(:abbreviation => 'Deliv. Meth.')
    customer_delivery_method(:name => 'Delivery Method (long)')
  end
end
