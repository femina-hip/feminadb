class SpecialOrderNotesController < ApplicationController
  require_role 'edit-special-orders', :except => [ :new, :create ]
  before_filter :login_required

  make_resourceful do
    actions :new, :create, :destroy
    belongs_to :special_order

    before(:create) do
      current_object.created_by = current_user.id
    end

    response_for(:create) do |format|
      format.html do
        set_default_flash(:notice, 'Note successfully created.')
        set_default_redirect parent_path
      end
      format.js
    end

    response_for(:destroy) do |format|
      format.html do
        set_default_flash(:notice, 'Note successfully deleted.')
        set_default_redirect parent_path
      end
      format.js
    end
  end

  def destroy
    #load_object
    before :destroy
    if current_object.soft_delete
      after :destroy
      response_for :destroy
    else
      after :destroy_fails
      response_for :destroy_fails
    end
  end

  protected

  def parent_path
    # Work around bug in make_resourceful
    special_order_path(parent_object)
  end

  def instance_variable_name
    'notes'
  end
end
