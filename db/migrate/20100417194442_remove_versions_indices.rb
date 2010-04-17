class RemoveVersionsIndices < ActiveRecord::Migration
  def self.up
    change_table(:versions) do |t|
      t.remove_index(:number)
      t.remove_index(:created_at)
      t.remove_index(:tag)
      t.remove_index([:user_id, :user_type])
      t.remove_index(:user_name)
      t.index([:versioned_id, :versioned_type, :number])
    end
  end

  def self.down
    change_table(:versions) do |t|
      t.index(:number)
      t.index(:created_at)
      t.index(:tag)
      t.index([:user_id, :user_type])
      t.index(:user_name)
      t.remove_index([:versioned_id, :versioned_type, :number])
    end
  end
end
