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
            AND customer_type_id IN (SELECT id FROM customer_types WHERE category = 'Educational Institutions')
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
            AND customer_type_id IN (SELECT id FROM customer_types WHERE category = 'Educational Institutions')
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

    def school_contacts
      result = Customer.connection.select_all <<-EOT
        SELECT
          regions.name,
          regions.manager AS staff_member,
          COUNT(*) AS n_schools,
          SUM(schools.has_fema) AS n_schools_with_fema,
          regions.population,
          SUM(schools.n_fema) AS n_fema,
          regions.population / SUM(schools.n_fema) AS population_per_fema,
          SUM(schools.has_telerivet) AS n_schools_with_telerivet,
          100 * SUM(schools.has_telerivet) / COUNT(*) AS percent_schools_with_telerivet,
          SUM(schools.has_fema * schools.has_telerivet) AS n_schools_with_fema_and_telerivet,
          100.0 * SUM(schools.has_fema * schools.has_telerivet) / SUM(schools.has_fema) AS percent_fema_schools_with_telerivet,
          SUM(schools.has_club) AS n_schools_with_club,
          100.0 * SUM(schools.has_club) / COUNT(*) AS percent_schools_with_club,
          100.0 * SUM(schools.has_club) / SUM(schools.has_fema) AS percent_fema_schools_with_club
        FROM regions
        INNER JOIN (
          SELECT
            region_id,
            EXISTS(
              SELECT 1
              FROM standing_orders
              WHERE customer_id = customers.id
              AND publication_id = (SELECT id FROM publications WHERE name = 'Fema')
          ) AS has_fema,
            COALESCE((
              SELECT num_copies
              FROM standing_orders
              WHERE customer_id = customers.id
              AND publication_id = (SELECT id FROM publications WHERE name = 'Fema')
          ), 0) AS n_fema,
            LENGTH(REGEXP_REPLACE(CONCAT(primary_contact_sms_numbers, headmaster_sms_numbers, club_sms_numbers, student_sms_numbers), '[^+]', '')) AS n_telerivet,
          INSTR(CONCAT(primary_contact_sms_numbers, headmaster_sms_numbers, club_sms_numbers, student_sms_numbers), '+') > 0 AS has_telerivet,
          INSTR(club_sms_numbers, '+') AS has_club
          FROM customers
          WHERE customer_type_id IN (SELECT id FROM customer_types WHERE category = 'Educational Institutions')
        ) schools ON regions.id = schools.region_id
        GROUP BY regions.name, regions.manager, regions.population
        ORDER BY regions.name
      EOT

      result.to_hash.map(&:symbolize_keys!)
    end
  end
end
