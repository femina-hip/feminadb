class ReportsController < ApplicationController
  def show
    case params[:id]
    when 'staff-schools-clubs' then show_staff_schools_clubs
    when 'school-contacts' then show_school_contacts
    else raise ActiveRecord::RecordNotFound.new("Invalid report name: #{params[:id]}")
    end
  end

  private

  def show_staff_schools_clubs
    @table = Reports.staff_schools_clubs
    render('staff-schools-clubs')
  end

  def show_school_contacts
    @table = Reports.school_contacts
    render('school-contacts')
  end
end
