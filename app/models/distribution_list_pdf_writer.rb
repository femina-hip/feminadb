require 'pdf/writer'

class DistributionListPdfWriter
  include ActionView::Helpers::NumberHelper

  class Measurements
    attr_reader :paper, :margin, :ibs_width, :customer_width, :delivery_instructions_width

    def initialize
      @paper = 'A4'
      @margin = 32
      @ibs_width = 32
      @customer_width = 160
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
      p = PDF::Writer.new(:paper => m.paper)

      # "="'s needed because PDF::Writer is a bit wonky
      p.add_info(
        'Creator=' => 'FeminaDB',
        'Producer=' => 'FeminaDB',
        'Title=' => 'Distribution List',
        'Author=' => 'Femina HIP Ltd.'
      )

      p.margins_pt m.margin

      h1 p, 'Distribution List'
      h2 p, "for #{issue.full_name}"

      p.start_page_numbering p.absolute_x_middle, 28, 8, :center, 'Page <PAGENUM>'
      first = true

      issue.distribution_list_data.each do |dm, regions|
        next if delivery_method and dm != delivery_method

        p.start_new_page if not first
        h2 p, "#{dm.name}: #{dm.description}"

        regions.each do |region, districts|
          h3 p, "#{region.name} (Total #{number_with_delimiter(districts.total(:num_copies))})"
          districts.each do |district, orders|
            h4 p, district
            show_headings p
            orders.each do |order|
              show_order p, order
            end
          end
        end

        first = false
      end

      p
    end

    def h1(p, s)
      return if not s
      p.save_state
      p.select_font 'Helvetica-Bold'
      p.text s, :font_size => 20, :justification => :center
      p.restore_state
    end

    def h2(p, s)
      return if not s
      p.save_state
      p.select_font 'Helvetica-Bold'
      p.text s, :font_size => 17, :justification => :center
      p.restore_state
    end

    def h3(p, s)
      return if not s
      p.save_state
      p.move_pointer 10
      p.select_font 'Helvetica-Bold'
      p.text s, :font_size => 14
      p.restore_state
    end

    def h4(p, s)
      return if not s
      p.save_state
      p.move_pointer 5
      p.select_font 'Helvetica-Bold'
      p.text s, :font_size => 12, :left => 10
      p.move_pointer 5
      p.restore_state
    end

    def show_headings(p)
      p.save_state

      p.move_pointer 13

      p.select_font 'Times-Bold'
      p.add_text_wrap p.absolute_left_margin + 20, p.y, m.customer_width, 'Final Recipient', 10
      p.add_text_wrap p.absolute_left_margin + 20 + m.customer_width, p.y, m.delivery_instructions_width, 'Delivery Instructions', 10

      x = p.absolute_right_margin - m.ibs_width
      issue.issue_box_sizes.reverse.each do |ibs|
        p.add_text_wrap x, p.y, m.ibs_width, "x#{ibs.num_copies}", 10, :right
        x -= m.ibs_width
      end
      p.add_text_wrap x, p.y, m.ibs_width, "Qty", 10, :right

      p.restore_state
    end

    def show_order(p, order)
      p.save_state

      p.move_pointer 13

      p.select_font 'Times-Roman'
      p.add_text_wrap p.absolute_left_margin + 20, p.y, m.customer_width, order.customer_name, 10
      p.add_text_wrap p.absolute_left_margin + 20 + m.customer_width, p.y, m.delivery_instructions_width, order.deliver_via, 10

      x = p.absolute_right_margin - m.ibs_width
      issue.issue_box_sizes_i.reverse.each do |ibs|
        p.add_text_wrap x, p.y, m.ibs_width, order.num_boxes[ibs].to_s, 10, :right
        x -= m.ibs_width
      end
      p.add_text_wrap x, p.y, m.ibs_width, number_with_delimiter(order.num_copies), 10, :right

      p.stroke_style?.width = 0.4
      p.stroke_color Color::RGB::Grey50
      p.line(p.absolute_left_margin + 20, p.y - 2, p.absolute_right_margin, p.y - 2)
      p.stroke

      p.restore_state
    end
end
