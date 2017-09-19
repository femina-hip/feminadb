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
        WHERE regions.manager <> ''
        GROUP BY regions.manager
        ORDER BY regions.manager
      EOT

      result
        .to_hash
        .map do |row|
          row.symbolize_keys!
          row[:percent_fema_schools_with_clubs] = 100.0 * row[:n_clubs] / row[:n_schools_with_fema]
          row
        end
    end

    # Returns info for each region concerning number of schools+contacts.
    def school_contacts
      result = Customer.connection.select_all <<-EOT
        SELECT
          regions.name,
          regions.manager AS staff_member,
          regions.n_schools,
          SUM(schools.has_fema) AS n_schools_with_fema,
          100 * SUM(schools.has_fema) / regions.n_schools AS percent_schools_with_fema,
          regions.population,
          SUM(schools.n_fema) AS n_fema,
          regions.population / SUM(schools.n_fema) AS population_per_fema,
          SUM(schools.has_fema * schools.has_headmaster_telerivet) AS n_schools_with_fema_and_headmaster_telerivet,
          100.0 * SUM(schools.has_fema * schools.has_headmaster_telerivet) / SUM(schools.has_fema) AS percent_fema_schools_with_headmaster_telerivet,
          SUM(schools.has_club) AS n_schools_with_club,
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
          INSTR(headmaster_sms_numbers, '+') > 0 AS has_headmaster_telerivet,
          INSTR(club_sms_numbers, '+') > 0 AS has_club
          FROM customers
          WHERE customer_type_id IN (SELECT id FROM customer_types WHERE name LIKE 'SS %')
        ) schools ON regions.id = schools.region_id
        GROUP BY regions.name, regions.manager, regions.n_schools, regions.population
        ORDER BY regions.name
      EOT

      result.to_hash.map(&:symbolize_keys!)
    end

    # Returns a row per phone number, for comparison with Telerivet
    def contact_list
      # We really want something like Postgres's UNNEST() to turn the String
      # values like "+255123123123 +255234234234" into two rows. But MySQL can't
      # do that. We simulate with a subquery.

      def sql_regex_i(i, contact_type)
        # SQL snippet. Regex will return the (i+1)th phone number from a string
        # like "+255123123123, +255234234234" -- or the empty string if i is
        # greater than the number of numbers.
        "REGEXP_REPLACE(REGEXP_REPLACE(#{contact_type}_sms_numbers, '^([+][0-9]+[, ]*){0,#{i}}', ''), '[, ].*$', '')"
      end

      def sql_i(i, contact_type)
        # Watch the missing escape on contact_type. (Types are hard-coded
        # and don't have quotes.)
        <<-EOT
          SELECT
            id AS customer_id,
            '#{contact_type}' AS contact_type,
            #{sql_regex_i(i, contact_type)} AS sms
          FROM customers
          WHERE #{sql_regex_i(i, contact_type)} <> ''
        EOT
      end

      sql = <<-EOT
        SELECT
          smss.sms,
          smss.contact_type,
          regions.name AS region_name,
          customers.council,
          customers.name,
          smss.customer_id
        FROM
          (
                  #{sql_i(0, 'headmaster')}
            UNION #{sql_i(1, 'headmaster')}
            UNION #{sql_i(2, 'headmaster')}
            UNION #{sql_i(3, 'headmaster')}
            UNION #{sql_i(4, 'headmaster')}
            UNION #{sql_i(5, 'headmaster')}
            UNION #{sql_i(6, 'headmaster')}
            UNION #{sql_i(7, 'headmaster')}
            UNION #{sql_i(0, 'club')}
            UNION #{sql_i(1, 'club')}
            UNION #{sql_i(2, 'club')}
            UNION #{sql_i(3, 'club')}
            UNION #{sql_i(4, 'club')}
            UNION #{sql_i(5, 'club')}
            UNION #{sql_i(6, 'club')}
            UNION #{sql_i(7, 'club')}
          ) smss
        INNER JOIN customers ON smss.customer_id = customers.id
        INNER JOIN regions ON customers.region_id = regions.id
        ORDER BY regions.name, customers.council, smss.contact_type, customers.name
      EOT

      result = Customer.connection.select_all(sql)

      result.to_hash.map(&:symbolize_keys!)
    end
  end
end
