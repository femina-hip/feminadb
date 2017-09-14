module Reports
  class <<self
    # Returns rows of [ staff member, # school standing orders, # clubs, percent clubs ]
    def staff_schools_clubs
      result = Customer.connection.select_all <<-EOT
        SELECT
          regions.manager AS staff_member,
          SUM((
            SELECT COUNT(*)
            FROM customers
            WHERE region_id = regions.id
            AND customer_type_id IN (SELECT id FROM customer_types WHERE name LIKE 'SS %')
          )) AS n_schools,
          SUM((
            SELECT COUNT(*)
            FROM customers
            WHERE region_id = regions.id
            AND customer_type_id IN (SELECT id FROM customer_types WHERE name LIKE 'SS %')
            AND EXISTS (
              SELECT 1
              FROM standing_orders
              WHERE customer_id = customers.id
              AND publication_id = (SELECT id FROM publications WHERE name = 'Fema')
            )
          )) AS n_schools_with_fema,
          SUM((
            SELECT COUNT(*)
            FROM customers
            WHERE region_id = regions.id
            AND club_sms_numbers <> ''
            AND customer_type_id IN (SELECT id FROM customer_types WHERE name LIKE 'SS %')
          )) AS n_clubs
        FROM regions
        GROUP BY manager
      EOT

      result
        .to_hash
        .map do |row|
          row.symbolize_keys!
          row[:percent_fema_schools_with_clubs] = 100.0 * row[:n_clubs] / row[:n_schools_with_fema]
          row
        end
    end
  end
end
