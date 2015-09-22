class IssueNotesController < ApplicationController
  def new
    require_role 'edit-issues'
    @issue = publication.issues.build
  end

  def create
    require_role 'edit-issues'
    @issue = create_with_audit(Issue, issue_create_params)
    if @issue.valid?
      redirect_to(@issue.publication)
    else
      render(action: new)
    end
  end

  def destroy
    require_role 'edit-issues'
    publication = issue.publication
    destroy_with_audit(issue)
    redirect_to(publication)
  end

  protected

  def publication
    @publication ||= Publication.find(params[:publication_id])
  end

  def issue
    @issue ||= Issue.find(params[:issue_id])
  end

  def note
    @note ||= IssueNote.find(params[:id])
  end

  def issue_create_params
    params.require(:issue).permit(
      :publication_id,
      :name,
      :issue_date,
      :issue_number,
      :quantity,
      :price,
      :packing_hints
    )
  end
end
