class Tag < ActiveRecord::Base
  has_and_belongs_to_many(:customers, dependent: :delete)
end
