class SpecialOrderLine < ActiveRecord::Base
  # acts_as_paranoid
  versioned
  acts_as_reportable

  belongs_to :special_order
  belongs_to :issue

  validates_presence_of :special_order_id,
                        :if => Proc.new { |sol| not sol.new_record? }
  validates_presence_of :issue_id
  validates_presence_of :num_copies_requested
  validate :must_be_non_zero
  validate :must_be_allowed_for_this_issue

  def denied?
    special_order.state != :pending and num_copies == 0
  end

  private
    def must_be_non_zero
      errors.add_to_base('Cannot request 0 copies') unless num_copies_requested != 0
    end

    def must_be_allowed_for_this_issue
      errors.add_to_base('This Issue does not allow new Special Order lines') if new_record? && !issue.allows_new_special_orders
    end
end
