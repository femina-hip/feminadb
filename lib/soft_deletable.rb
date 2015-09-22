module SoftDeletable
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods
    def active
      self.where(deleted_at: nil)
    end
  end

  def soft_delete(options = {})
    self.class.transaction do
      !soft_delete_would_delete_protected_dependents? && update_attributes(options.merge(:deleted_at => Time.now)) && soft_delete_dependents(options)
    end
  end

  def soft_delete!(options = {})
    soft_delete(options) || raise(ActiveRecord::RecordNotSaved)
  end

  def soft_delete_would_delete_protected_dependents?
    self.class.reflect_on_all_associations.any? do |assoc|
      assoc.collection? && soft_delete_would_delete_protected_dependent?(assoc)
    end
  end

  private

  def soft_delete_would_delete_protected_dependent?(assoc)
    if assoc.options[:dependent] == :restrict && !send(assoc.name).empty?
      return true
    end

    # Don't recurse: it's too slow. So we might screw up! Sorry.
    false
  end

  def soft_delete_dependents(options)
    self.class.reflect_on_all_associations.each do |assoc|
      if [:destroy, :delete_all].include?(assoc.options[:dependent]) && assoc.name != :versions
        soft_delete_assoc(assoc, options)
      end
    end
  end

  def soft_delete_assoc(assoc, options)
    Rails.logger.warn("Assoc #{assoc.name}... destroy!")
    # soft-delete anything soft-deletable (:has_one, :has_many, :has_many_through, :has_and_belongs_to_many)
    # raise error if we'd have to delete something permanently
    raise ActiveRecord::ReferentialIntegrityProtectionError.new("Can't soft-delete because of #{assoc.name}") unless assoc.klass.method_defined?(:soft_delete)

    to_delete = send(assoc.name)

    if assoc.collection?
      begin
        to_delete.each { |o| o.soft_delete(options) }
      rescue ActiveRecord::UnknownAttributeError
        # In case options includes "updated_by" but the assoc isn't versioned, remove that option
        to_delete.each(&:soft_delete)
      end
    elsif !to_delete.nil?
      to_delete.soft_delete(options)
    end
  end
end
