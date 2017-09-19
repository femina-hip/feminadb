class ReportsController < ApplicationController
  respond_to(:csv, :html)

  def show
    case params[:id]
    when 'staff-schools-clubs' then show_staff_schools_clubs
    when 'school-contacts' then show_school_contacts
    when 'contact-list' then show_contact_list
    else raise ActiveRecord::RecordNotFound.new("Invalid report name: #{params[:id]}")
    end
  end

  private

  def show_staff_schools_clubs
    @table = Reports.staff_schools_clubs
    respond('staff-schools-clubs')
  end

  def show_school_contacts
    @table = Reports.school_contacts
    respond('school-contacts')
  end

  def show_contact_list
    @table = Reports.contact_list
    respond('contact-list')
  end

  # Either sends @table to render(view_name), or renders @table as a CSV.
  def respond(view_name)
    respond_with do |format|
      format.html { render(view_name) }
      format.csv { render_csv(view_name) }
    end
  end

  def render_csv(view_name)
    csv = CSV.generate(headers: true) do |out|
      keys = @table[0].keys
      out << keys

      @table.each do |row|
        out << keys.map { |key| row[key] }
      end
    end
    send_data(csv, filename: "#{view_name}.csv")
  end
end
