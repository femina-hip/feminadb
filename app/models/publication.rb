class Publication < ActiveRecord::Base
  include SoftDeletable
  #versioned

  has_many(:issues)
  has_many(:standing_orders)
  has_many(:waiting_orders)
  has_many(:customers, through: :standing_orders)

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :deleted_at, :if => lambda { |p| p.deleted_at.nil? }

  scope :tracking_standing_orders, -> { where(tracks_standing_orders: true).order(:name) }
  scope :current_periodicals, -> { where(tracks_standing_orders: true).order(:name) }
  scope :not_pr_material, -> { where(pr_material: false).order([ [ :tracks_standing_orders, :DESC ], :name ]) }

  def to_index_key
    name.parameterize.gsub(/-/, '_')
  end

  def title; name; end
end
