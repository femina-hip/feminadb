class SurveyResponsesController < ApplicationController
  def edit
    if params[:id] == 'random-unlinked'
      # Workflow: user will link this response to a customer and then link
      # another one.
      conditions = {}
      conditions[:region_name] = params[:region_name] if params[:region_name]
      @survey_response = SurveyResponse.find_random_unlinked(conditions)
      @redirect_to = edit_survey_response_path(region_name: params[:region_name])
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
