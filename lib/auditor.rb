# Stores an audit trail, so admins can delve into the database's history.
#
# The audit trail basically stores each database row as it was created, edited
# or deleted, all in the `audits` table. There is no logic to restore those old
# rows: such a feature may *sound* nice, but it's impossible in general because
# it means different things for different tables.
#
# Also, controllers must explicitly audit whatever needs auditing. Auditing
# isn't automatic, because sometimes we'd rather not audit things. For
# instance, we don't need to audit the automatic destruction of `has_many`
# children if we've audited the destruction of the parent row.
#
# Audit if and only if the answer to "would an administrator ever want to see
# this?" is "yes".
#
# These methods will all fail unless there is a `current_user` method in scope.
#
# This module handles a few Rails paradigms:
#
#   object = create_with_audit(SomeClass, param1: value1)
#   if object.valid?
#     # the object was saved and audited
#   else
#     # the object was neither saved nor audited. Check object.errors.
#   end
#
#   if update_with_audit(object, param1: value2)
#     # object.valid? == true, and the object was saved and audited.
#   else
#     # the object was neither saved nor audited. Check object.errors.
#   end
#
# Don't use Rails paradigms not documented here: they won't work.
module Auditor
  # Logs the creation of an object.
  #
  # Usage:
  #
  #   object = SomeClass.create(attributes)
  #   audit_create(object)
  def audit_create(object)
    Audit.create!(
      created_at: Time.current,
      user_email: current_user.email,
      table_name: object.class.table_name,
      record_id: object.respond_to?(:id) && object.id || nil,
      action: 'create',
      before: {},
      after_json: object.attributes
    )
  end

  # Creates an object and logs the creation.
  #
  # Usage:
  #
  #  # instead of `customer = Customer.create(name: 'foo')`
  #  customer = create_with_audit!(Customer, name: 'foo')
  #
  #  # instead of `note = customer.notes.create(text: 'foo')`
  #  note = create_with_audit!(customer.notes, text: 'foo')
  #
  # The audit happens after the insert succeeds. Run in a transaction to avoid
  # inconsistencies.
  #
  # Returns the object.
  def create_with_audit!(relation, attributes)
    object = relation.create!(attributes)
    audit_create(object)
    object
  end

  # Creates an object and logs the creation.
  #
  # Usage:
  #
  #  # instead of `customer = Customer.create(name: 'foo')`
  #  customer = create_with_audit(Customer, name: 'foo')
  #  # if !customer.valid?, the database is unchanged; check customer.errors.
  #
  #  # instead of `note = customer.notes.create(text: 'foo')`
  #  note = create_with_audit(customer.notes, text: 'foo')
  #  # if !note.valid?, the database is unchanged; check note.errors.
  #
  # The audit happens after the insert succeeds. Run in a transaction to avoid
  # inconsistencies.
  #
  # Returns the object.
  def create_with_audit(relation, attributes)
    object = relation.create(attributes)
    audit_create(object) if object.valid?
    object
  end

  # Logs the destruction of an object.
  #
  # Usage:
  #
  #   object.destroy
  #   audit_destroy(object)
  def audit_destroy(object)
    Audit.create(
      created_at: Time.current,
      user_email: current_user.email,
      table_name: object.class.table_name,
      record_id: object.respond_to?(:id) && object.id || nil,
      action: 'destroy',
      before: object.attributes,
      after: {}
    )
  end

  # Destroys an object and audits its destruction
  #
  # The audit happens after the delete succeeds. Run in a transaction to avoid
  # inconsistencies.
  #
  # Returns the result of object.destroy -- that's the object (if it was
  # destroyed) or false (if it wasn't).
  def destroy_with_audit(object)
    ret = object.destroy
    audit_destroy(object) if ret
    ret
  end

  # Audit the change of an object.
  #
  # Usage:
  #
  #   old_attributes = object.attributes
  #   object.update(new_attributes)
  #   audit_update(object, old_attributes, object.attributes)
  #
  # The usage is clunky because that makes for more readable code. For briefer
  # code, use update_with_audit().
  def audit_update(object, old_attributes, new_attributes)
    Audit.create!(
      created_at: Time.current,
      user_email: current_user.email,
      table_name: object.class.table_name,
      record_id: object.respond_to?(:id) && object.id || nil,
      action: 'update',
      before: old_attributes,
      after: new_attributes
    )
  end

  # Updates an object in the database, and audits the update.
  #
  # The audit happens after the update succeeds. Run in a transaction to avoid
  # inconsistencies.
  #
  # Returns the object.
  def update_with_audit!(object, attributes)
    old_attributes = object.attributes
    object.update!(attributes)
    audit_update(object, old_attributes, object.attributes)
    object
  end

  # Updates an object in the database, and audits the update.
  #
  # The audit happens after the update succeeds. Run in a transaction to avoid
  # inconsistencies.
  #
  # Returns true iff the update passed validations.
  def update_with_audit(object, attributes)
    old_attributes = object.attributes
    saved = object.update(attributes)
    audit_update(object, old_attributes, object.attributes) if saved
    saved
  end
end
