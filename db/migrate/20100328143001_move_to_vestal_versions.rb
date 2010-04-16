class MoveToVestalVersions < ActiveRecord::Migration
  def self.up
    transaction do
      tables_to_migrate.each do |table|
        move_versions_for_table(table)
      end
    end
  end

  def self.down
    execute("DELETE FROM versions");
  end

  private

  def self.tables_to_migrate
    [ :clubs, :customer_types, :customers, :districts, :issue_box_sizes, :issues, :orders, :publications, :regions, :special_order_lines, :special_orders, :standing_orders, :waiting_orders, :warehouse_issue_box_sizes ]
  end

  def self.move_versions_for_table(table)
    versions_table = "#{table.to_s.singularize}_versions".to_sym
    id_column = "#{table.to_s.singularize}_id".to_sym

    execute("DELETE FROM #{quote_table_name(versions_table.to_s)} WHERE #{quote_column_name(id_column.to_s)} NOT IN (SELECT id FROM #{quote_table_name(table.to_s)})")

    ids = select_values("SELECT #{quote_column_name(id_column.to_s)} FROM #{quote_table_name(versions_table.to_s)} WHERE version = 2") # If there are 2 or more versions, we need to migrate it

    return if ids.empty?

    all_rows = select_all("SELECT * FROM #{quote_table_name(versions_table.to_s)} WHERE #{quote_column_name(id_column.to_s)} IN (#{ids.join(',')}) ORDER BY #{quote_column_name(id_column.to_s)}, version DESC")

    rows_by_id = {}

    all_rows.each do |row|
      row['id'] = row.delete(id_column.to_s).to_i
      rows_by_id[row['id']] ||= []
      rows_by_id[row['id']] << row
    end

    rows_by_id.each do |id, versions|
      move_versions_for_record(table, id, versions)
    end
  end

  def self.move_versions_for_record(table, id, versions)
    created_at = versions.last['updated_at']

    hash = {
      :versioned_id => id,
      :versioned_type => table.to_s.singularize.camelize,
      :created_at => created_at
    }

    current = versions.shift

    versions.each do |version|
      hash[:number] = current.delete('version').to_i
      hash[:updated_at] = current.delete('updated_at')
      hash[:user_id] = current.delete('updated_by')
      hash[:user_type] = hash[:user_id] && 'User'

      changes = {}
      current.each do |key, val|
        earlier = version[key]
        later = current[key]

        if earlier != later
          changes[key] = [ earlier, later ]
        end
      end
      hash[:changes] = changes.to_yaml

      fixture = PseudoFixture.new(hash, self)
      execute("INSERT INTO versions (#{fixture.key_list}) VALUES (#{fixture.value_list})")

      current = version
    end

    hash.merge!(
      :number => 1,
      :updated_at => created_at,
      :user_id => current.delete(:updated_by)
    )
    hash[:user_type] = hash[:user_id] && 'User'

    fixture = PseudoFixture.new(hash, self)
    execute("INSERT INTO versions (#{fixture.key_list}) VALUES (#{fixture.value_list})")
  end

  class PseudoFixture
    def initialize(hash, connection)
      @connection = connection
      @key_list_array = []
      @value_list_array = []

      hash.each do |key, value|
        @key_list_array << key.to_s
        @value_list_array << value
      end
    end

    def key_list
      @key_list_array.join(', ') # We know column names don't need quoting
    end

    def value_list
      @value_list_array.collect{|v| @connection.quote(v).gsub('[^\]\\n', "\n").gsub('[^\]\\r', "\r")}.join(', ')
    end
  end
end
