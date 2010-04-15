class ClubObserver < ActiveRecord::Observer
  def after_save(club)
    club.customer.index
  end

  def after_destroy(club)
    # This doesn't get called, because Clubs are soft-deleted
    # But let's throw it in anyway
    club.customer.index
  end
end
