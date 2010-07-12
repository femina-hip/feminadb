module NavigationHelpers
  # Put here the helper methods related to the paths of your applications
  
  def homepage
    "/"
  end

  def customers_index
    homepage
  end

  def login_path
    "/login"
  end
end

RSpec.configuration.include(NavigationHelpers)
