class SurveyResponsesController < ApplicationController
  def edit
    if params[:id] == 'random-unlinked'
      # Workflow: user will link this response to a customer and then link
      # another one.

      conditions = {}
      conditions[:region_name] = params[:region_name] if params[:region_name]
      @region_name = params[:region_name] || 'Tanzania'
      @n_missing_survey_responses = SurveyResponse.where(conditions).where(reviewed_at: nil).count

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
    @survey_response = SurveyResponse.find(params[:id])
    @redirect_to = params[:redirect_to]

    new_attributes = {
      reviewed_at: params[:unreview] ? nil : DateTime.now,
      customer_id: params[:unreview] ? nil : (survey_response_params[:customer_id] || nil)
    }
    if update_with_audit(@survey_response, new_attributes)
      redirect_to(@redirect_to)
    else
      render('edit')
    end
  end

  private

  def survey_response_params
    params.require(:survey_response).permit(:customer_id)
  end
end
