class AddSurveyResponsesReviewedAt < ActiveRecord::Migration[5.1]
  def change
    add_column(:survey_responses, :reviewed_at, :datetime, null: true)
    remove_column(:survey_responses, :no_customer, :boolean, null: false, default: false)
  end
end
