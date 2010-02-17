class IssueNotesController < ApplicationController
  require_role 'edit-issues'

  # make_resourceful does not work nicely with deeply-nested resources.
  # This code is not all that beautiful and should not be used as an
  # example.
  make_resourceful do
    actions :new, :create, :destroy
    belongs_to :issue

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Note successfully created.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Note successfully deleted.')
        set_default_redirect parent_path
      end
      format.js
    end
  end

  protected
    def instance_variable_name
      'notes'
    end

    def objects_path
      publication_issue_notes_path(@issue.publication, @issue)
    end

    def parent_path
      publication_issue_path(@issue.publication, @issue)
    end
end
