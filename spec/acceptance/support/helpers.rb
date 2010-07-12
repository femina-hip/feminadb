module HelperMethods
  def login(login, password)
    visit(login_path)
    within('div.main form') do
      fill_in('Login', :with => login)
      fill_in('Password', :with => password)
      click_button('Log in')
    end
  end
end

RSpec.configuration.include(HelperMethods)
