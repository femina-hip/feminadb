class TelerivetLinksController < ApplicationController
  def new
    require_role 'edit-customers'

    # When Telerivet gives a link, it puts "+" cool the URL.
    if params[:sms_number].present? and params[:sms_number][0] == ' '
      params[:sms_number][0] = '+'
    end

    @telerivet_link = TelerivetLink.new(new_telerivet_link_params)
  end

  def create
    require_role 'edit-customers'
    @telerivet_link = TelerivetLink.new(telerivet_link_params)
    if @telerivet_link.valid?
      customer = Customer.find(@telerivet_link.customer_id)
      customer.add_sms_number(@telerivet_link.attribute, @telerivet_link.sms_number)
      save_with_audit!(customer)
      customer.solr_index!
      redirect_to(customer)
    else
      render(action: 'new')
    end
  end

  private

  def new_telerivet_link_params
    params.permit(:sms_number)
  end

  def telerivet_link_params
    params.require(:telerivet_link).permit(:sms_number, :customer_id, :attribute)
  end
end
