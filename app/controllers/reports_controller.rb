class ReportsController < ApplicationController
  def show
    case params[:id]
    when 'staff-schools-clubs' then show_staff_schools_clubs
    else raise ActiveRecord::RecordNotFound.new("Invalid report name: #{params[:id]}")
    end
  end

  private

  def show_staff_schools_clubs
    @table = Reports.staff_schools_clubs
    render('staff-schools-clubs')
  end
end
