module WillPaginate
  module Finder
    module ClassMethods
      def paginate_search(query, options = {}, find_options = {})
        page, per_page, total_entries = wp_parse_options!(options)
        pager = WillPaginate::Collection.new(page, per_page, nil)
        options.merge!(:offset => pager.offset, :limit => per_page)
        result = find_by_contents(query, options, find_options)
        returning WillPaginate::Collection.new(page, per_page, result.total_hits) do |pager|
          pager.replace result
        end
      end
    end
  end
end
