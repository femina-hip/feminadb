class ClubObserver < ActiveRecord::Observer
  def after_save(club)
    club.customer.ferret_update
  end
end
