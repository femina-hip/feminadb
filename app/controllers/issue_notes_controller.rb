class IssueNotesController < ApplicationController
  def new
    require_role 'edit-issues'
    @issue_note = IssueNote.new
  end

  def create
    require_role 'edit-issues'
    @issue_note = create_with_audit(issue.notes.create_with(created_by: current_user.id), issue_note_params)
    if @issue_note.valid?
      redirect_to(issue)
    else
      render(action: new)
    end
  end

  def destroy
    require_role 'edit-issues'
    destroy_with_audit(issue_note)
    redirect_to(issue)
  end

  protected

  def publication
    @publication ||= Publication.find(params[:publication_id])
  end

  def issue
    @issue ||= Issue.find(params[:issue_id])
  end

  def issue_note
    @note ||= IssueNote.find(params[:id])
  end

  def issue_note_params
    params.require(:issue_note).permit(:note)
  end
end
