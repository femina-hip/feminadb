class SurveyResponse < ActiveRecord::Base
  belongs_to(:customer)

  QuestionResponse = RubyImmutableStruct.new(:question_id, :answers_json)

  validates_absence_of(:customer, if: :no_customer?)

  def self.find_random_unlinked(conditions = {})
    SurveyResponse
      .where(conditions)
      .where(customer_id: nil)
      .where(no_customer: false)
      .order('RAND()').limit(1)
      .first
  end

  def sm_data
    @sm_data ||= JSON.parse(sm_data_json)
  end

  def question_responses
    @question_responses ||= sm_data['pages'].flat_map do |page_json|
      page_json['questions'].map do |json|
        QuestionResponse.new(question_id: json['id'], answers_json: json['answers'])
      end
    end
  end
end
