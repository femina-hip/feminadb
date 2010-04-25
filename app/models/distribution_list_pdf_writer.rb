class DistributionListPdfWriter
  include ActionView::Helpers::NumberHelper

  class Measurements
    attr_reader :paper, :margin, :ibs_width, :customer_width, :delivery_instructions_width

    def initialize
      @paper = 'A4'
      @margin = 32
      @ibs_width = 32
      @customer_width = 196
      @delivery_instructions_width = 196
    end
  end

  attr_reader :issue, :delivery_method

  def initialize(issue, delivery_method = nil)
    @issue = issue
    @delivery_method = delivery_method
    @m = Measurements.new
  end

  def pdf
    @pdf ||= generate_pdf
  end

  private

  attr_reader :m

  def generate_pdf
    p = Prawn::Document.new(
      :page_size => m.paper,
      :margin => m.margin,
      :compress => true,
      :info =>  {
        'Creator' => 'FeminaDB',
        'Producer' => 'FeminaDB',
        'Title' => 'Distribution List',
        'Author' => 'Femina HIP Ltd.'
      }
    ) do |p|
      h1(p, 'Distribution List')
      h2(p, "for #{issue.full_name}")
      first = true

      issue.distribution_list_data.each do |dm, regions|
        next if delivery_method and dm != delivery_method

        p.start_new_page if not first
        h2(p, "#{dm.name}: #{dm.description}")

        regions.each do |region, districts|
          h3(p, "#{region.name} (Total #{number_with_delimiter(districts.total(:num_copies))})")
          districts.each do |district, orders|
            h4(p, district)

            p.font('Times-Roman')
            show_orders(p, orders)
          end
        end

        first = false
      end

      p.save_graphics_state do
        p.font('Helvetica', :size => 8)
        p.number_pages('Page <page> of <total>', [p.bounds.width/2,0])
      end
    end
  end

  def h1(p, s)
    return if not s
    p.font('Helvetica-Bold', :size => 20)
    p.text(s, :align => :center)
  end

  def h2(p, s)
    return if not s
    p.font('Helvetica-Bold', :size => 17)
    p.text(s, :align => :center)
  end

  def h3(p, s)
    return if not s
    p.move_down(10)
    p.font('Helvetica-Bold', :size => 14)
    p.text(s, :align => :center)
  end

  def h4(p, s)
    return if not s
    p.move_down(5)
    p.font('Helvetica-Bold', :size => 12)
    p.text(s)
    p.move_down(5)
  end

  def show_orders(p, orders)
    headers = ['Customer', 'Delivery Instructions', 'Qty']
    num_sizes = 0
    orders.first.issue.issue_box_sizes_i.each do |n|
      next if n == 1
      headers << "x#{n}"
      num_sizes += 1
    end

    column_widths = [ m.customer_width, m.delivery_instructions_width, m.ibs_width] + ([m.ibs_width] * num_sizes)

    orders_lists = orders.collect{ |o| make_order_into_list(o) }

    aligns = [ :left, :left, :center ] + ([:center] * num_sizes)

    p.table(orders_lists,
      :position => :center,
      :headers => headers,
      :align_headers => list_to_hash(aligns),
      :font_size => 10,
      :border_style => :underline_header,
      :column_widths => list_to_hash(column_widths)
    )
  end

  def list_to_hash(list)
    returning({}) do |hash|
      list.each_with_index { |value, i| hash[i] = value }
    end
  end

  def make_order_into_list(order)
    returning([]) do |ret|
      ret << order.customer_name
      ret << order.deliver_via

      ret << order.num_copies.to_s

      order.issue.issue_box_sizes_i.each do |ibs|
        next if ibs == 1

        n = order.num_boxes[ibs]

        if n == 0
          ret << ""
        else
          ret << n.to_s
        end
      end
    end
  end
end
