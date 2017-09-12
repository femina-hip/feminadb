class Publication < ActiveRecord::Base
  has_many(:issues, -> { order(issue_date: :desc) })
  has_many(:standing_orders)
  has_many(:customers, through: :standing_orders)

  validates_presence_of :name
  validates_uniqueness_of :name

  scope :tracking_standing_orders, -> { where(tracks_standing_orders: true).order(:name) }
  scope :not_pr_material, -> { where(pr_material: false).order([ { tracks_standing_orders: :desc }, :name ]) }

  def to_index_key
    name.parameterize.gsub(/-/, '_')
  end

  def title; name; end

  def standing_order_num_copies
    Publication.connection.execute("""
      SELECT SUM(num_copies)
      FROM standing_orders
      WHERE publication_id = #{id}
    """).first[0]
  end
end
