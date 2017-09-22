class ChangeSurveysToCsv < ActiveRecord::Migration[5.1]
  def change
    # Meh. Wipe and start over.
    execute 'DELETE FROM survey_responses'
    execute 'DELETE FROM surveys'

    remove_column(:surveys, :sm_data_json, :text)
    remove_column(:surveys, :sm_id, :string)
    add_column(:surveys, :sm_data_csv, :text, limit: 16.megabytes - 1, null: false)
    
    remove_column(:survey_responses, :sm_id, :string)
    remove_column(:survey_responses, :sm_data_json, :text)
    add_column(:survey_responses, :sm_respondent_id, :string, null: false)
    add_column(:survey_responses, :answers_json, :text, null: false)
  end
end
