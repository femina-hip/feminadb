module OauthStrategy
  # Either returns [ 'user', user ] or [ 'redirect', "http://some/url" ]
  def self.authenticate(request)
    if request.session[:user_email]
      authenticate_user(request)
    else
      start_oauth(request)
    end
  end

  def self.ask_google_about_code(request)
    response = Net::HTTP.post_form(URI("https://www.googleapis.com/oauth2/v3/token"),
      code: request.params['code'],
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri(request),
      grant_type: 'authorization_code'
    )
    if response.code != '200'
      raise Exception, "Google gave us an authentication token and then denied it"
    end
    response_json = JSON.parse(response.body)
    id_token = JWT.decode(response_json['id_token'], nil, false)[0]
  end

  private

  def self.authenticate_user(request)
    email = request.session[:user_email]
    user = User.find_by_email(email)
    if !user
      raise Exception, 'This user does not exist'
    end
    [ 'user', user ]
  end

  def self.start_oauth(request)
    escaped_redirect_uri = Rack::Utils.escape(redirect_uri(request))
    escaped_target_uri = Rack::Utils.escape(request.url) # TODO make state include CSRF token
    [ 'redirect', "https://accounts.google.com/o/oauth2/auth?client_id=#{client_id}&response_type=code&scope=openid+email&redirect_uri=#{escaped_redirect_uri}&state=#{escaped_target_uri}&login_hint=jsmith@feminahip.or.tz&hd=feminahip.or.tz" ]
  end

  def self.client_id
    Rails.application.secrets.oauth_client_id
  end

  def self.client_secret
    Rails.application.secrets.oauth_client_secret
  end

  def self.redirect_uri(request)
    port_part = case request.scheme
      when "http" then request.port == 80 ? "" : ":#{request.port}"
      when "https" then request.port == 443 ? "" : ":#{request.port}"
      else ":#{request.port}"
    end
    "#{request.scheme}://#{request.host}#{port_part}/oauth2callback"
  end
end
