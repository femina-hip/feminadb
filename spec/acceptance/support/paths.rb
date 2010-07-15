module NavigationHelpers
  # Put here the helper methods related to the paths of your applications
  
  def homepage
    "/"
  end

  def customers_index(q = '')
    "/customers?q=#{q}"
  end

  def customer_path(customer)
    "/customers/#{customer.id}"
  end

  def login_path
    "/login"
  end
end

RSpec.configuration.include(NavigationHelpers)
