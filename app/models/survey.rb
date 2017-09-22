class Survey < ActiveRecord::Base
  has_many(:survey_responses, dependent: :delete_all)

  CreateOrRefreshStatus = RubyImmutableStruct.new(:error, :survey, :n_created, :n_updated, :n_deleted)
  Question = RubyImmutableStruct.new(:json)

  # Create or update a Survey and its SurveyResponses through a CSV.
  def self.create_or_update_and_return_status(id, title, csv)
    survey = id.blank? ? Survey.new : Survey.find(id)
    csv_text = csv.to_io.set_encoding('utf-8').read

    # Return error right away if parse fails
    region_names_set = Region.all.map(&:name).to_set
    sm_csv = begin
      SurveyMonkey::Survey.parse_csv(csv_text, region_names_set)
    rescue ArgumentError => e
      return CreateOrRefreshStatus.new(survey: survey, error: "Failed to parse SurveyMonkey CSV: #{e.message}")
    end

    survey.title = title
    survey.sm_data_csv = csv_text
    survey.updated_at = DateTime.now
    survey.save or return CreateOrRefreshStatus.new(survey: survey, error: "Could not save Survey: #{survey.errors.to_s}")

    sm_responses = sm_csv.responses
    # Now we need to delete+update+create to make survey.responses look like
    # sm_responses.

    # 1. Do all the deletes.
    n_deleted = SurveyResponse
      .where(survey_id: survey.id)
      .where.not(sm_respondent_id: sm_responses.map(&:respondent_id))
      .delete_all

    # Hash all the remaining responses. Delete from the hash when updating
    # existing responses; then use the remaining values to create new responses.
    by_sm_respondent_id = sm_responses.index_by(&:respondent_id)

    # 2. Update the responses we have
    n_updated = survey.survey_responses.count
    survey.survey_responses.each do |response|
      sm_response = by_sm_respondent_id.delete(response.sm_respondent_id)
      response.update!(
        region_name: sm_response.region_name,
        start_date: sm_response.start_date,
        end_date: sm_response.end_date,
        answers_json: sm_response.answers.to_json
      )
    end

    # 3. Create new responses
    n_created = by_sm_respondent_id.values.length
    by_sm_respondent_id.values.each do |sm_response|
      SurveyResponse.create!(
        survey_id: survey.id,
        start_date: sm_response.start_date,
        end_date: sm_response.end_date,
        region_name: sm_response.region_name,
        sm_respondent_id: sm_response.respondent_id,
        answers_json: sm_response.answers.to_json
      )
    end

    CreateOrRefreshStatus.new(nil, survey, n_created, n_updated, n_deleted)
  end

  def sm_data
    @sm_data ||= JSON.parse(sm_data_json)
  end

  def questions
    @questions ||= sm_data['pages'].flatten.map { |json| Question.new(json) }
  end
end
