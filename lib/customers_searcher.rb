module CustomersSearcher
  def self.apply_query_string_to_search(search_object, query)
    search_object.with(:deleted, false)

    leftover_terms = []

    (query || '').scan(/\w+:"[^"]*"|\w+:'[^']*'|\w+:\w+|\w+/) do |term|
      if term.nil? || term == ''
        next
      end

      if term =~ /^(.*?):(.*)$/
        keyword = $1
        value = $2

        if value =~ /^"(.*)"$/ || value =~ /^'(.*)'$/
          value = $1
        end

        search_object.text_fields { with(keyword.to_sym, value) }
      else
        leftover_terms << term
      end
    end

    unless leftover_terms.empty?
      search_object.keywords(leftover_terms.join(' '))
    end
  end
end
