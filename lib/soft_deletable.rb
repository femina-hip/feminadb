module SoftDeletable
  def soft_delete(options = {})
    self.class.transaction do
      !soft_delete_would_delete_protected_dependents? && update_attributes(options.merge(:deleted_at => Time.now)) && soft_delete_dependents
    end
  end

  def soft_delete!(options = {})
    soft_delete(options) || raise(ActiveRecord::RecordNotSaved)
  end

  def soft_delete_would_delete_protected_dependents?
    reflect_on_all_associations.any? do |assoc|
      assoc.collection? && assoc.soft_delete_would_delete_protected_dependent?(assoc)
    end
  end

  private

  def soft_delete_would_delete_protected_dependent?(assoc)
    if assoc.options[:dependent] == :protect && !send(assoc.name).empty?
      return true
    end

    # Don't recurse: it's too slow. So we might screw up! Sorry.
    false
  end

  def soft_delete_dependents(options)
    reflect_on_all_associations.each { |assoc| soft_delete_assoc(assoc, options) }
  end

  def soft_delete_assoc(assoc, options)
    # soft-delete anything soft-deletable (:has_one, :has_many, :has_many_through, :has_and_belongs_to_many)
    # raise error if we'd have to delete something permanently
    to_delete = send(assoc.name)
    if assoc.collection?
      to_delete.each { |o| o.soft_delete(options) }
    else
      to_delete.soft_delete(options)
    end
  end
end
