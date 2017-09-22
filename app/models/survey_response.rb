class SurveyResponse < ActiveRecord::Base
  belongs_to(:customer)

  validates_absence_of(:customer, if: :no_customer?)
end
