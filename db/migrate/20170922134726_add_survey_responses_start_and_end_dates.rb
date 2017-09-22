class AddSurveyResponsesStartAndEndDates < ActiveRecord::Migration[5.1]
  def change
    add_column(:survey_responses, :start_date, :datetime, null: false)
    add_column(:survey_responses, :end_date, :datetime, null: false)
  end
end
