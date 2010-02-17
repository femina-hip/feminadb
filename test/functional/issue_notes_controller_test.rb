require File.dirname(__FILE__) + '/../test_helper'
require 'issue_notes_controller'

class IssueNotesControllerTest < ActionController::TestCase
  fixtures :publications, :issues, :issue_notes, :users, :roles, :roles_users

  def test_should_get_new
    login_as :admin
    get :new, :publication_id => 1, :issue_id => 1
    assert_response :success
  end

  def test_should_create_issue_note
    login_as :admin
    old_count = IssueNote.count
    post :create, :publication_id => 1, :issue_id => 1, :issue_note => { :note => 'Testing' }
    assert_equal old_count + 1, IssueNote.count

    assert_redirected_to publication_issue_path(1, 1)
  end

  def test_should_destroy_issue_note
    login_as :admin
    old_count = IssueNote.count
    delete :destroy, :publication_id => 1, :issue_id => 1, :id => 1
    assert_equal old_count-1, IssueNote.count

    assert_redirected_to publication_issue_path(1, 1)
  end
end
