class SurveyResponsesController < ApplicationController
  def edit
    if params[:id] == 'random-unlinked'
      # Workflow: user will link this response to a customer and then link
      # another one.
      @survey_response = SurveyResponse.find_random_unlinked(region_name: params[:region_name])
      @redirect_to = edit_survey_responses_path(params.to_h)
    else
      # Workflow: the user spotted a linking error on a customer and has come
      # to fix it
      #
      # ... or the user is just fiddling with URLs.
      @survey_response = SurveyResponse.find(params[:id])
      @redirect_to = customer_path(@survey_response.customer_id)
    end
  end

  def update
  end
end
