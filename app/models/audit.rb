class Audit < ActiveRecord::Base
  serialize(:before)
  serialize(:after)

  searchable(auto_index: true) do
    integer(:record_id)
    string(:table_name)
    time(:created_at)
    text(:all) { [ user_email, action, before.to_s.encode('utf-8'), after.to_s.encode('utf-8') ].join(' ') }
  end

  # Returns an Array of [ 'attribute', 'before', 'after' ]
  def changed_attributes
    @changed_attributes ||= begin
      attributes = Set.new([])
      attributes.merge(before.keys)
      attributes.merge(after.keys)

      attributes.to_a
        .map { |key| [ key, before[key], after[key] ] }
        .select { |row| row[1].to_s != row[2].to_s }
        .sort!
    end
  end
end
