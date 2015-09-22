class ClubsController < ApplicationController
  include CustomerFilterControllerMethods

  def index
    conditions = {}

    customers = search_for_customers(
      :includes => [ :region, :club ],
      :order => [ :region, :district, :name ]
    ) do
      with(:club, true)
    end

    @clubs = customers.dup # WillPaginate magic
    @clubs.replace(customers.collect(&:club))

    respond_to do |format|
      format.html # index.html.haml
      format.csv do
        Club.send(:preload_associations, @clubs, :customer => [ :type, :delivery_method ])
        render(:csv => @clubs)
      end
    end
  end

  def show
    @club = club
  end

  def new
    require_role 'edit-customers'
    @club = customer.build_club
  end

  def edit
    require_role 'edit-customers'
    @club = club
  end

  def create
    require_role 'edit-customers'

    club = create_with_audit(club_create_params)
    if club.valid?
      redirect_to(club.customer)
    else
      render(action: 'new')
    end
  end

  def update
    require_role 'edit-customers'

    if update_with_audit(club, club_update_params)
      redirect_to(club.customer)
    else
      render(action: 'edit')
    end
  end

  def destroy
    require_role 'edit-customers'
    customer = club.customer
    destroy_with_audit(club)
    redirect_to(customer)
  end

  private

  def club
    @club ||= Club.find(params[:id])
  end

  def club_create_params
    params.require(:club).permit(
      :customer_id,
      :name,
      :address,
      :telephone_1,
      :telephone_2,
      :email,
      :num_members,
      :date_founded,
      :motto,
      :objective,
      :eligibility,
      :work_plan,
      :patron,
      :intended_duty,
      :founding_motivation,
      :cooperation_ideas
    )
  end

  def club_update_params
    params.require(:club).permit(
      :name,
      :address,
      :telephone_1,
      :telephone_2,
      :email,
      :num_members,
      :date_founded,
      :motto,
      :objective,
      :eligibility,
      :work_plan,
      :patron,
      :intended_duty,
      :founding_motivation,
      :cooperation_ideas
    )
  end
end
