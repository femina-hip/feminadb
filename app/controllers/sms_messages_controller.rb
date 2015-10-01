class SmsMessagesController < ApplicationController
  def index
    @customer = Customer.find(params[:customer_id])
    @sms_messages = @customer.sms_messages
    render('_sms_messages', layout: nil)
  end
end
