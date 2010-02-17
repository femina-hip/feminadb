class Tag < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  validate :name_is_normalized
  validate :positive_num_customers

  def normalized_name
    Tags.normalize_name(name)
  end

  def normalize_name!
    self.name = normalized_name
  end

  private
    def positive_num_customers
      errors.add(:num_customers, 'must be greater than 0') unless num_customers > 0
    end

    def name_is_normalized
      errors.add(:name, 'must look LIKE_THIS') unless name == normalized_name
    end
end
