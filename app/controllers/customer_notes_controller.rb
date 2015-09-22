class CustomerNotesController < ApplicationController
  def create
    require_role 'edit-customers'
    create_with_audit!(customer.notes, note_params)
    redirect_to(customer)
  end

  def destroy
    require_role 'edit-customers'
    destroy_with_audit(note)
    redirect_to(customer)
  end

  protected

  def customer
    @customer ||= Customer.find(params[:customer_id])
  end

  def note
    @note ||= CustomerNote.find(params[:id])
  end

  def note_params
    params.require(:customer_note).permit(:note)
  end
end
