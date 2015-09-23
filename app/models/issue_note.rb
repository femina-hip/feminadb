class IssueNote < ActiveRecord::Base
  belongs_to(:issue)
  belongs_to(:created_by_user, class_name: 'User', foreign_key: :created_by)

  validates_presence_of :issue_id
  validates_length_of :note, :minimum => 3
end
