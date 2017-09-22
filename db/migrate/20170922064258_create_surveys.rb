class CreateSurveys < ActiveRecord::Migration[5.1]
  def change
    create_table(:surveys) do |t|
      t.datetime(:created_at, null: false)
      t.datetime(:updated_at, null: false)
      t.string(:title, null: false)
      t.string(:sm_id, null: false)
      t.text(:sm_data_json, null: false)
    end

    create_table(:survey_responses) do |t|
      t.datetime(:created_at, null: false)
      t.integer(:customer_id, null: true)
      t.integer(:survey_id, null: false)
      t.boolean(:no_customer, null: false, default: false)
      t.string(:sm_id, null: false)
      t.text(:sm_data_json, null: false)
    end
  end
end
