class CustomerNotesController < ApplicationController
  def create
    require_role 'edit-customers'
    create_with_audit!(customer.notes, note_params)
    customer.solr_index!
    redirect_to(customer)
  end

  def destroy
    require_role 'edit-customers'
    destroy_with_audit(note)
    customer.solr_remove_from_index!
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
    ret = params.require(:customer_note).permit(:note).to_h
    ret[:created_by] = current_user.id
    ret
  end
end
