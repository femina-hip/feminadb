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

    @surveys = Survey.order(:title).all
    @survey = Survey.new
  end

  def create
    require_role('admin')

    status = Survey.create_or_update_and_return_status(survey_params[:id], survey_params[:title], survey_params[:csv])
    if status.error
      @surveys = Survey.order(:title).all
      @survey = Survey.new
      @survey.errors.add(:sm_csv_text, status.error)
      render('new')
    else
      flash[:notice] = "Imported '#{status.survey.title}': #{status.n_created} responses created, #{status.n_deleted} deleted, #{status.n_updated} updated"
      redirect_to(admin_surveys_path)
    end
  end

  def destroy
    require_role('admin')

    Survey.find(params[:id]).destroy
    redirect_to(admin_surveys_url)
  end

  private

  def survey_params
    params.require(:survey).permit(:id, :title, :csv)
  end
end
