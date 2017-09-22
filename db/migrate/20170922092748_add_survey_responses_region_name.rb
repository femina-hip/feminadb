class AddSurveyResponsesRegionName < ActiveRecord::Migration[5.1]
  def change
    add_column(:survey_responses, :region_name, :string, null: false, default: '')
  end
end
