# Queries SurveyMonkey and returns JSON.
#
# Error handling (nascent doc!): HTTP errors if communication fails; undefined
# behavior if SurveyMonkey returns something we don't expect.
module SurveyMonkey
  SurveySummary = RubyImmutableStruct.new(:id, :title)
  SurveyDetails = RubyImmutableStruct.new(:id, :created_at, :title, :json)
  SurveyResponse = RubyImmutableStruct.new(:id, :survey_id, :created_at, :json)

  class << self
    # Array of SurveySummary objects
    def get_survey_summaries
      get_json('https://api.surveymonkey.net/v3/surveys?per_page=1000')['data'].map do |json|
        SurveySummary.new(id: json['id'], title: json['title'])
      end
    end

    # SurveyDetails object
    def get_survey_details(sm_id)
      json = get_json("https://api.surveymonkey.net/v3/surveys/#{sm_id}/details")
      SurveyDetails.new(
        id: json['id'],
        created_at: DateTime.parse(json['date_created'] + 'Z'),
        title: json['title'],
        json: json
      )
    end

    def get_survey_responses(sm_id)
      next_url = "https://api.surveymonkey.net/v3/surveys/#{sm_id}/responses/bulk?page=1&per_page=100"
      responses = []
      while !next_url.blank?
        response = get_json(next_url)
        responses << response
        next_url = response['links']['next']
      end

      responses.flat_map do |response|
        response['data'].map do |json|
          SurveyResponse.new(
            id: json['id'],
            survey_id: json['survey_id'],
            created_at: DateTime.parse(json['date_created']),
            json: json
          )
        end
      end
    end

    private

    def logger; Rails.logger; end
    include ActiveSupport::Benchmarkable

    def get_json(url)
      benchmark("GET #{url}") do
        uri = URI.parse(url)
        req = Net::HTTP::Get.new(uri)
        req['Content-Type'] = 'application/json'
        req['Authorization'] = "bearer #{Rails.application.secrets.surveymonkey_api_access_token}"
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          JSON.parse(http.request(req).body)
        end
      end
    end
  end
end
