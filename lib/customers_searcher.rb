module CustomersSearcher
  def self.apply_query_string_to_search(search_object, query)
    search_object.with(:deleted, false)

    search_as_hash = {}
    leftover_terms = []

    (query || '').scan(/\w+:"[^"]*"|\w+:'[^']*'|\w+:[<>=\w]+|\w+/) do |term|
      if term.nil? || term == ''
        next
      end

      if term =~ /^(.*?):(.*)$/
        keyword = $1
        value = $2

        if value =~ /^"(.*)"$/ || value =~ /^'(.*)'$/
          value = $1
        end

        search_as_hash[keyword] ||= []
        search_as_hash[keyword] << value
      else
        leftover_terms << term
      end
    end

    if club = search_as_hash.delete('club')
      search_object.with(:club, club == 'yes')
    end

    search_as_hash.each do |key, values|
      if key =~ /^(standing|waiting)_([\w_]+)/
        standing_or_waiting = $1.to_sym
        publication = $2.to_sym

        search_object.dynamic(standing_or_waiting) do
          values.each do |value|
            if value =~ /([<>=]?)(\d+)/
              comparator = s_to_comparator_sym($1)
              integer = $2.to_i

              with(publication).send(comparator, integer)
            end
          end
        end
      else
        values.each do |value|
          search_object.text_fields { with(key.to_sym, value) }
        end
      end
    end

    unless leftover_terms.empty?
      search_object.keywords(leftover_terms.join(' '))
    end
  end

  def self.s_to_comparator_sym(s)
    case s
    when '>' then :greater_than
    when '<' then :less_than
    else :equal_to
    end
  end
end
