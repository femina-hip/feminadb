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
    Capybara.current_session.driver.browser.set_cookie(fake_request.cookie_jar.to_header)
  end
end

RSpec.configuration.include(HelperMethods)
