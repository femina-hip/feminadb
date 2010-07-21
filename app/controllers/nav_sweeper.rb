class NavSweeper < ActionController::Caching::Sweeper
  observe Publication, Issue

  def after_create(record)
    sweep
  end

  def after_update(record)
    sweep
  end

  def after_destroy(record)
    sweep
  end

  private

  def sweep
    expire_fragment('nav_admin')
    expire_fragment('nav_not_admin')
  end
end
