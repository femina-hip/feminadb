class Audit < ActiveRecord::Base
  serialize(:before)
  serialize(:after)

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
