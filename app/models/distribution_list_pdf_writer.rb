class DistributionListPdfWriter
  include ActionView::Helpers::NumberHelper

  class Measurements
    attr_reader :paper, :margin, :ibs_width, :customer_width, :delivery_instructions_width

    def initialize
      @paper = 'A4'
      @margin = 32
      @ibs_width = 32
      @customer_width = 180
      @delivery_instructions_width = 180
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
            show_headings(p)
            p.font('Times-Roman', :size => 10)
            orders.each do |order|
              show_order(p, order)
            end
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

  def show_headings(p)
    p.font('Times-Bold', :size => 10)
    p.text('Final Recipient', :width => m.customer_width)
    p.move_up(p.font_size + 1)
    p.text_box('Delivery Instructions', :at => [m.customer_width,p.cursor], :width => m.delivery_instructions_width)

    x = p.bounds.width - m.ibs_width
    issue.issue_box_sizes.reverse.each do |ibs|
      p.text_box("x#{ibs.num_copies}", :at => [x,p.cursor], :width => m.ibs_width, :align => :right)
      x -= m.ibs_width
    end
    p.text_box('Qty', :at => [x,p.cursor], :width => m.ibs_width, :align => :right)
    p.move_down(p.font_size + 3)
  end

  def show_order(p, order)
    p.text(order.customer_name, :width => m.customer_width)
    p.move_up(p.font_size + 1)
    p.text_box(order.deliver_via, :at => [m.customer_width,p.cursor], :width => m.delivery_instructions_width)

    x = p.bounds.width - m.ibs_width
    issue.issue_box_sizes_i.reverse.each do |ibs|
      p.text_box(order.num_boxes[ibs].to_s, :at => [x,p.cursor], :width => m.ibs_width, :align => :right)
      x -= m.ibs_width
    end
    p.text_box(number_with_delimiter(order.num_copies), :at => [x,p.cursor], :width => m.ibs_width, :align => :right)
    p.move_down(p.font_size)

    p.stroke do
      p.line_width(0.4)
      p.stroke_color('888888')
      p.horizontal_rule
    end

    p.move_down(3)
  end
end
