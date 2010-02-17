require 'xmpp4r'
require 'xmpp4r/presence'

class XMPP
  def send_message(recipients, body)
    client = create_client

    recipients.each_with_index do |recipient, i|
      # We send an authorization request NO MATTER WHAT.
      # This is because it's difficult to code a way to check whether we
      # are already "subscribed" to the user. The code in question is:
      #   roster = Jabber::Roster::Helper.new(client)
      #   item = roster['adamh@feminahip.or.tz']
      #   item and [:to, :both].include?(item.subscription)
      # Unfortunately, the Roster is not populated instantaneously, so this
      # code will invariably return nil.
      #
      # There seems to be no harm in sending two authorization requests.
      #
      # If the user has authorized us, send_authorization_request() will do
      # nothing.
      #
      # If the user has not authorized us, do_send_message() will do
      # nothing. This is bad because the message is lost; oh well.
      send_authorization_request(client, recipient)
      do_send_message(client, recipient, body, i + 1)
    end

    client.close
  end

  private
    def create_client
      jid = CONFIG.read('messenger', 'jid')
      host = CONFIG.read('messenger', 'host')
      password = CONFIG.read('messenger', 'password')

      client = Jabber::Client.new Jabber::JID.new(jid)
      client.connect host
      client.auth password
      client
    end

    def send_authorization_request(client, jid)
      subscription_request = Jabber::Presence.new.set_type(:subscribe)
      subscription_request.to = jid
      client.send subscription_request
    end

    def do_send_message(client, jid, message, counter)
      m = Jabber::Message.new(jid, message).set_type(:normal).set_id(counter.to_s)
      client.send m
    end
end
