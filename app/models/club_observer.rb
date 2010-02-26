class ClubObserver < ActiveRecord::Observer
  def after_save(club)
    club.customer.index
  end
end
