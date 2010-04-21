class StandingOrder < ActiveRecord::Base
  include SoftDeletable
  versioned

  belongs_to :customer
  belongs_to :publication

  validates_presence_of :customer_id
  validates_presence_of :publication_id
  validates_uniqueness_of :publication_id, :scope => [ :customer_id, :deleted_at ], :if => lambda { |so| so.deleted_at.nil? }
  validates_numericality_of :num_copies, :integer => true, :greater_than => 0
  validate :publication_tracks_standing_orders

  private

  def publication_tracks_standing_orders
    errors.add(:publication_id, 'does not track Standing Orders') unless publication.tracks_standing_orders?
  end
end
