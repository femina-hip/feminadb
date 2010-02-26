class Customer < ActiveRecord::Base
  extend Forwardable

  acts_as_paranoid
  versioned
  acts_as_reportable

  STOP_WORDS = Ferret::Analysis::FULL_ENGLISH_STOP_WORDS - [ 'yes', 'no' ]

  def self.ferret_fields
    normal = { :store => :no, :term_vector => :no }
    sortable = { :store => :yes, :index => :untokenized, :term_vector => :no }
    ret = {
      :region_name_for_sorting => sortable,
      :district_for_sorting => sortable,
      :name_for_sorting => sortable,
      :delivery_method_abbreviation_for_sorting => sortable,
      :type_name_for_sorting => sortable,
      :type_category_for_sorting => sortable,
      # columns
      :district => normal,
      :name => normal,
      :contact_name => normal,
      :deliver_via => normal,
      :address => normal,
      :full_name => normal,
      :contact_position => normal,
      :telephone_1 => normal,
      :telephone_2 => normal,
      :telephone_3 => normal,
      :fax => normal,
      :email_1 => normal,
      :email_2 => normal,
      :website => normal,
      :po_box => normal,
      # derived
      :delivery_method_abbreviation => normal,
      :delivery_method_name => normal,
      :customer_note_text => normal,
      :region_name => normal,
      :type_name => normal,
      :type_description => normal,
      :type_category => normal,
      :club_yes_no => normal
    }
    Club.column_names.each do |c|
      ret["club_#{c}"] = normal
    end

    ret
  end

  acts_as_ferret(
    :remote => true,
    :fields => ferret_fields,
    :ferret => { :analyzer => Ferret::Analysis::StandardAnalyzer.new(STOP_WORDS) }
  )

  belongs_to :type, :class_name => 'CustomerType',
             :foreign_key => 'customer_type_id'
  belongs_to :delivery_method
  belongs_to :region
  belongs_to :updated_by_user,
             :class_name => 'User',
             :foreign_key => :updated_by
  has_many :standing_orders,
           :dependent => :destroy,
           :include => [ :publication ],
           :order => 'publications.name',
           :conditions => 'standing_orders.deleted_at IS NULL'
  has_many :waiting_orders,
           :dependent => :destroy,
           :include => [ :publication ],
           :order => 'publications.name',
           :conditions => 'waiting_orders.deleted_at IS NULL'
  has_many :orders,
           :dependent => :nullify,
           :include => { :issue => :publication },
           :order => 'publications.name, issues.issue_number DESC',
           :conditions => 'orders.deleted_at IS NULL'
  has_many :special_orders,
           :dependent => :nullify,
           :order => 'special_orders.requested_for_date DESC',
           :conditions => 'special_orders.deleted_at IS NULL'
  has_many :special_order_lines,
           :through => :special_orders,
           :source => :lines,
           :include => { :issue => :publication },
           :order => 'publications.name, issues.issue_number, special_orders.requested_for_date DESC',
           :conditions => 'special_order_lines.deleted_at IS NULL'
  has_many :notes,
           :dependent => :destroy,
           :class_name => 'CustomerNote',
           :conditions => 'customer_notes.deleted_at IS NULL'
  has_one :club,
          :dependent => :destroy,
          :conditions => 'clubs.deleted_at IS NULL'

  validates_presence_of :region_id
  validates_presence_of :customer_type_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :region_id, :district ],
                          :case_sensitive => false
  validates_presence_of :delivery_method_id

  before_validation :clear_deliver_via_if_same_as_name

  def delivery_method_name
    delivery_method.name
  end

  def delivery_method_abbreviation
    delivery_method.abbreviation
  end
  alias_method :delivery_method_abbreviation_for_sorting, :delivery_method_abbreviation

  def region_name
    region.name
  end
  alias_method :region_name_for_sorting, :region_name

  def name_for_sorting
    name
  end

  def district_for_sorting
    if district.nil? or district.empty?
      'AAA'
    else
      district
    end
  end

  Club.column_names.each do |a|
    define_method("club_#{a}".to_sym) { club and club.send(a.to_sym) }
  end

  def customer_note_text
    notes.collect{|n| n.note}.join(' ')
  end

  def type_name
    type.name
  end
  alias_method :type_name_for_sorting, :type_name

  def type_description
    type.description
  end

  def type_category
    type.category
  end
  alias_method :type_category_for_sorting, :type_category

  def club_yes_no
    club and 'yes' or 'no'
  end

  def deliver_via_string
    (deliver_via and not deliver_via.empty? and deliver_via != name) ? "via #{deliver_via}" : nil
  end

  def delivery_instructions
    [ deliver_via_string, address ].reject{|x| x.nil?}.join(', ')
  end

  def contact_details_string
    [ telephone_1, email_1, telephone_2, email_2, telephone_3, fax ].select{|x| not x.nil? }[0..2].join(', ')
  end

  class << self
    def records_for_rebuild_with_includes(batch_size = 1000)
      with_scope(:find => { :include => [ :region, :club, :delivery_method, :type ] }) do
        records_for_rebuild_without_includes(batch_size) do |rows, offset|
          yield rows, offset
        end
      end
    end
    alias_method_chain :records_for_rebuild, :includes
  end

  private
    def clear_deliver_via_if_same_as_name
      if deliver_via == name
        write_attribute :deliver_via, nil
      end
      true # Returning false will cancel save
    end
end
