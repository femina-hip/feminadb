class Admin::SurveysController < ApplicationController
  PotentialSmSurvey = RubyImmutableStruct.new(:sm_id, :sm_title, :survey) do
    def title
      if survey
        "#{sm_title} (last downloaded #{survey.updated_at})"
      else
        sm_title
      end
    end
  end

  def index
    require_role('admin')

    @surveys = Survey.order(created_at: :desc).all
  end

  def new
    require_role('admin')

    by_sm_id = Survey.order(created_at: :desc).index_by(&:sm_id)
    @potential_surveys = SurveyMonkey.get_survey_summaries.map do |sm_survey|
      PotentialSmSurvey.new(sm_survey.id, sm_survey.title, by_sm_id[sm_survey.id])
    end
    @survey = Survey.new
    @survey.errors.add(:sm_id, @error) if @error
  end

  def create
    require_role('admin')

    status = Survey.create_or_refresh_from_surveymonkey_and_return_status(survey_params[:sm_id])
    if status.error
      @error = status.error
      new
    else
      flash[:notice] = "Imported '#{status.survey.title}': #{status.n_created} responses created, #{status.n_deleted} deleted, #{status.n_updated} updated"
      redirect_to(admin_surveys_path)
    end
  end

  private

  def survey_params
    params.require(:survey).permit(:sm_id)
  end
end
