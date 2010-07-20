class RemoveUserId0 < ActiveRecord::Migration
  def self.up
    execute('UPDATE versions SET user_id = NULL, user_type = NULL WHERE user_id = 0')
  end

  def self.down
    # We can't, but why would we want to?
  end
end
