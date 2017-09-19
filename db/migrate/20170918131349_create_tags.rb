class CreateTags < ActiveRecord::Migration[5.1]
  def change
    execute 'DROP TABLE IF EXISTS tags' # cruft
    create_table :tags do |t|
      t.string(:name, null: false)
      t.string(:color, null: false)
    end

    # create_join_table() doesn't set a primary key. That allows duplicates.
    execute <<-EOT
      CREATE TABLE `customers_tags` (
        `customer_id` bigint(20) NOT NULL,
        `tag_id` bigint(20) NOT NULL,
        PRIMARY KEY (`customer_id`, `tag_id`),
        KEY `index_customers_tags_on_tag_id_and_customer_id` (`tag_id`,`customer_id`)
      )
    EOT
  end
end
