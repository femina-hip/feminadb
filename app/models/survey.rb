class Survey < ActiveRecord::Base
  has_many(:survey_responses, dependent: :delete_all)

  CreateOrRefreshStatus = RubyImmutableStruct.new(:error, :survey, :n_created, :n_updated, :n_deleted)

  def self.create_or_refresh_from_surveymonkey_and_return_status(sm_id)
    sm_survey = SurveyMonkey.get_survey_details(sm_id)
    survey = Survey.find_or_initialize_by(sm_id: sm_id)
    survey.title = sm_survey.title
    survey.sm_data_json = sm_survey.json
    survey.updated_at = DateTime.now
    survey.save or return CreateOrRefreshStatus.new(survey: survey, error: "Could not save Survey: #{survey.errors.to_s}")

    sm_responses = SurveyMonkey.get_survey_responses(sm_id)
    # Now we need to delete+update+create to make survey.responses look like
    # sm_responses.

    # 1. Do all the deletes.
    n_deleted = SurveyResponse
      .where(survey_id: survey.id)
      .where.not(sm_id: sm_responses.map(&:id))
      .delete_all

    # Hash all the remaining responses. Delete from the hash when updating
    # existing responses; then use the remaining values to create new responses.
    by_sm_id = sm_responses.index_by(&:id)

    # 2. Update the responses we have
    n_updated = survey.survey_responses.count
    survey.survey_responses.each do |response|
      sm_response = by_sm_id.delete(response.sm_id)
      response.update!(sm_data_json: sm_response.json)
    end

    # 3. Create new responses
    n_created = by_sm_id.values.length
    by_sm_id.values.each do |sm_response|
      SurveyResponse.create!(
        survey_id: survey.id,
        sm_id: sm_response.id,
        sm_data_json: sm_response.json
      )
    end

    CreateOrRefreshStatus.new(nil, survey, n_created, n_updated, n_deleted)
  end
end
