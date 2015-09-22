require 'net/http'

# Strategy to conect to Google.
#
# Based on https://github.com/atmos/warden-googleapps/blob/1f5bb3ab1125eebc052d3c6439cec9590e7f8a07/lib/warden-googleapps/strategy.rb
#
# Be aware: because of initialization stuff, this class is NOT automatically
# reloaded in development mode
class WardenGoogleStrategy < Warden::Strategies::Base
  def authenticate!
    if params.include?('code')
    if params['openid.mode']
      console
      response = ask_google_about_code(params['code'], request)
      console
    elsif params['RelayState']
      raise Exception, "only works with Google Apps"
    else
    end
  end
end
