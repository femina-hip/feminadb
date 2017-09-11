class SimplifyUsers < ActiveRecord::Migration[4.2]
  def up
    add_column(:users, :roles, :string)
    execute <<-SQL
      UPDATE users
      SET users.roles = (
        SELECT GROUP_CONCAT(r.name, ' ')
        FROM roles_users ru
        INNER JOIN roles r ON ru.role_id = r.id
        WHERE ru.user_id = users.id
          AND r.name NOT IN ('view', 'edit-inventory', 'edit-districts', 'edit-special-orders', 'edit-publications')
      )
    SQL
    drop_table(:roles_users)
    drop_table(:roles)
    remove_column(:users, :crypted_password)
    remove_column(:users, :salt)
    remove_column(:users, :remember_token)
    remove_column(:users, :remember_token_expires_at)
    remove_column(:users, :login)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
