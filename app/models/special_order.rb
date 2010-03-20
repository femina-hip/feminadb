class SpecialOrder < ActiveRecord::Base
  extend DateField

  # acts_as_paranoid
  versioned
  acts_as_reportable

  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  belongs_to :requested_by_user,
             :class_name => 'User',
             :foreign_key => :requested_by
  belongs_to :authorized_by_user,
             :class_name => 'User',
             :foreign_key => :authorized_by
  belongs_to :completed_by_user,
             :class_name => 'User',
             :foreign_key => :completed_by
  belongs_to :customer

  has_many :lines,
           :class_name => 'SpecialOrderLine',
           :dependent => :destroy,
           :include => { :issue => :publication },
           :order => 'publications.name, issues.issue_number DESC',
           :conditions => 'special_order_lines.deleted_at IS NULL'
  has_many :notes,
           :class_name => 'SpecialOrderNote',
           :dependent => :destroy,
           :order => 'created_at',
           :conditions => 'special_order_notes.deleted_at IS NULL'

  validates_presence_of :customer_name
  validates_presence_of :reason
  validates_presence_of :requested_at
  validates_presence_of :requested_for_date
  validates_presence_of :line_ids

  scope :pending, :conditions => 'special_orders.authorized_by IS NULL'
  scope :approved, :conditions => 'special_orders.approved = 1'
  scope :completed,
        :conditions => 'special_orders.completed_by IS NOT NULL'
  scope :incomplete_approved, :conditions => 'special_orders.approved = 1 AND special_orders.completed_by IS NULL'
  scope :denied, :conditions => 'special_orders.approved = 0 AND special_orders.authorized_by IS NOT NULL'

  date_field :requested_for_date

  def approve(by_user)
    if state != :pending
      @double_approve_or_deny = true
      return
    end
    write_authorization_timestamps(by_user)
    write_attribute :approved, true
  end

  def deny(by_user)
    if state != :pending
      @double_approve_or_deny = true
      return
    end
    write_authorization_timestamps(by_user)
    write_attribute :approved, false
  end

  def approved?
    approved
  end

  def denied?
    authorized_by.to_i != 0 and not approved
  end

  def complete(by_user)
    write_completed_timestamps(by_user)
  end

  def completed?
    completed_by.to_i != 0
  end

  def state
    return :completed if completed?
    return :approved if approved?
    return :denied if denied?
    :pending
  end

  def state_string
    case state
    when :completed then 'Completed'
    when :approved then 'Approved'
    when :denied then 'Denied'
    when :pending then 'Pending'
    end
  end

  def total_num_copies
    lines.inject(0){|s, l| s + (l.num_copies || l.num_copies_requested).to_i}
  end

  protected
    def validate
      if approved? and lines.select{|sol| sol.num_copies.to_i != 0}.empty?
        errors.add_to_base('Cannot approve without granting any Copies')
      end
      if completed? and not approved?
        errors.add_to_base('Cannot complete without approving first')
      end
      if @double_approve_or_deny
        errors.add_to_base('Order was already approved/denied')
      end
    end

  private
    def write_authorization_timestamps(by_user)
      write_attribute :authorized_by, by_user.id
      write_attribute :authorized_at, DateTime.now
    end

    def write_completed_timestamps(by_user)
      write_attribute :completed_by, by_user.id
      write_attribute :completed_at, DateTime.now
    end
end
