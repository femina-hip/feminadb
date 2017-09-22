class SurveyResponse < ActiveRecord::Base
  belongs_to(:customer)

  validates_absence_of(:customer, if: :no_customer?)

  def self.find_random_unlinked(conditions = {})
    SurveyResponse
      .where(conditions)
      .where(customer_id: nil)
      .where(no_customer: false)
      .order('RAND()').limit(1)
      .first
  end

  def response
    @response ||= SurveyMonkey::Response.from_active_record(self)
  end

  def answers
    response.answers
  end
end
