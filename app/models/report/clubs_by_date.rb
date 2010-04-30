class Report::ClubsByDate < Report::Base
  def data
    @data ||= begin
      by_month = {
        :num_clubs => Hash.new(0),
        :num_school_clubs => Hash.new(0),
        :num_tertiary_school_clubs => Hash.new(0),
        :num_out_of_school_clubs => Hash.new(0)
      }

      ss = CustomerType.find_by_name('SS')
      ts = CustomerType.find_by_name('TS')

      Club.active.includes(:customer => :type).each do |club|
        dt = club.created_at

        if dt.nil?
          by_month[nil] += 1
        else
          month = Date.new(dt.year, dt.month)
          by_month[:num_clubs][month] += 1
          if club.customer.type == ss
            by_month[:num_school_clubs][month] += 1
          elsif club.customer.type == ts
            by_month[:num_tertiary_school_clubs][month] += 1
          else
            by_month[:num_out_of_school_clubs][month] += 1
          end
        end
      end

      sorted_months = by_month[:num_clubs].keys.sort
      cur_month = sorted_months.first << 1
      last_month = sorted_months.last
      cur_count = by_month.keys.inject({}) { |h,k| h.merge!(k => 0) }

      ret = []
      while cur_month <= last_month
        cur_count.keys.each do |k|
          cur_count[k] += by_month[k][cur_month]
        end

        ret << [
          cur_month.strftime('%b %Y'), 
          cur_count[:num_clubs],
          cur_count[:num_school_clubs],
          cur_count[:num_tertiary_school_clubs],
          cur_count[:num_out_of_school_clubs]
        ]

        cur_month >>= 1
      end

      ret
    end
  end

  def columns
    [
      { :key => :month, :title => 'Month', :class => String },
      { :key => :num_clubs, :title => '# Clubs', :class => Integer },
      { :key => :num_school_clubs, :title => 'In-School', :class => Integer },
      { :key => :num_tertiary_school_clubs, :title => 'Tertiary School', :class => Integer },
      { :key => :num_out_of_school_clubs, :title => 'Out-of-School', :class => Integer }
    ]
  end

  class << self
    def title
      'Clubs over Time'
    end

    def description
      [
        'Displays the total number of Fema Clubs for every month since they were entered'
      ]
    end

    def graph_view
      'line'
    end
  end
end
