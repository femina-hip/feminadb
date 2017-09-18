module HelperMethods
  def login(login)
    # Users log in via OAuth. But we don't want every test to ping the Internet.
    # Forge the cookie we set after a successful login.
    fake_request = ActionDispatch::Request.new(Feminadb::Application.env_config)
    fake_request.cookie_jar.signed_or_encrypted[Feminadb::Application.config.session_options[:key]] = {
      value: {
        user_email: login
      }
    }
    fake_request.cookie_jar.each do |name, value|
      Capybara.current_session.driver.browser.manage.add_cookie(name: name, value: value)
    end
  end
end

RSpec.configuration.include(HelperMethods)
