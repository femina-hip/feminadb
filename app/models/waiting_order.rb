class WaitingOrder < ActiveRecord::Base
  extend DateField

  include SoftDeletable
  versioned
  acts_as_reportable

  belongs_to :customer
  belongs_to :publication

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_presence_of :request_date
  validates_uniqueness_of :publication_id, :scope => [ :customer_id, :deleted_at ], :if => lambda { |wo| wo.deleted_at.nil? }
  validates_inclusion_of :num_copies, :in => 1..9999999, :message => 'must be greater than 0'

  date_field :request_date

  # Returns a standing order and soft-deletes this waiting order
  #
  # Returns nil if the standing order couldn't be created
  def convert_to_standing_order(options = {})
    standing_order = nil
    transaction do
      standing_order = StandingOrder.new(options.merge(
        :customer_id => customer_id,
        :publication_id => publication_id,
        :num_copies => num_copies,
        :comments => "From Waiting Order #{request_date.to_formatted_s(:long)}: #{comments}"
      ))
      return nil unless standing_order.save
      soft_delete
    end
    standing_order
  end
end
