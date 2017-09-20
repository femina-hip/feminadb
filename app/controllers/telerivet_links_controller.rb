class TelerivetLinksController < ApplicationController
  def help
    @sms_number = help_params[:sms_number]
  end

  def new
    require_role 'edit-customers'

    @telerivet_link = TelerivetLink.new(
      attribute: new_params[:attribute].to_sym,
      customer: Customer.find(params[:customer_id])
    )

    render(layout: false)
  end

  def edit
    require_role 'edit-customers'

    @telerivet_link = TelerivetLink.new(
      attribute: edit_params[:attribute].to_sym,
      customer: Customer.find(params[:customer_id]),
      sms_number: params[:id]
    )

    render(layout: false)
  end

  def create
    require_role 'edit-customers'
    customer = Customer.find(params[:customer_id])
    @telerivet_link = TelerivetLink.new({ customer: customer }.merge(telerivet_link_params))
    if @telerivet_link.valid? && @telerivet_link.customer
      customer.add_sms_number(@telerivet_link)
      save_with_audit!(customer)
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: {
          li_html: render_to_string(partial: 'customers/editable_sms_number', locals: { customer: customer, sms_number: @telerivet_link.sms_number, attribute: @telerivet_link.attribute.to_sym }, formats: [ :html ])
        }) }
      end
    else
      render(action: 'new', layout: false)
    end
  end

  def destroy
    require_role 'edit-customers'
    customer = Customer.find(params[:customer_id])
    @telerivet_link = TelerivetLink.new(customer: customer, attribute: destroy_params[:attribute], sms_number: params[:id])
    if @telerivet_link.valid? && @telerivet_link.customer
      customer.remove_sms_number(@telerivet_link)
      telerivet_link2 = nil
      if @telerivet_link.attribute.to_sym != :old_sms_numbers
        telerivet_link2 = TelerivetLink.new({
          customer: customer,
          sms_number: @telerivet_link.sms_number,
          attribute: :old_sms_numbers,
        })
        customer.add_sms_number(telerivet_link2)
      end
      save_with_audit!(customer)
      customer.solr_index!
      respond_to do |format|
        format.html { redirect_to(customer) }
        format.json { render(json: {
          li_html: nil,
          old_sms_numbers_li_html: telerivet_link2.nil? ? nil : render_to_string(partial: 'customers/editable_sms_number', locals: { customer: customer, sms_number: telerivet_link2.sms_number, attribute: telerivet_link2.attribute.to_sym }, formats: [ :html ])
        }) }
      end
    else
      render(action: 'edit', layout: false)
    end
  end

  private

  def telerivet_link_params
    params.require(:telerivet_link).permit(:sms_number, :attribute, :contact_name)
  end

  def help_params
    params.permit(:sms_number)
  end

  def new_params
    params.permit(:attribute, :sms_number)
  end

  def edit_params
    params.permit(:attribute)
  end

  def destroy_params
    params.require(:telerivet_link).permit(:attribute)
  end
end
