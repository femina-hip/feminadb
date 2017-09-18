require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit standing orders from customer page", %q{
  In order to create and edit standing orders
  As a user with edit-orders privilege
  I want to use an edit standing orders form on the customers page
} do

  background do
    User.create!(email: 'order-editor@example.org', roles: 'edit-orders')
    login('order-editor@example.org')
  end
  
  scenario "Get an 'edit standing order' form when there's a standing order" do
    d = DeliveryMethod.create!(abbreviation: 'DM', name: 'delivery_method')
    r = Region.create!(name: 'region', delivery_method_id: d.id)
    t = CustomerType.create!(name: 'type', description: 'customer type')
    c = Customer.create!(name: 'name', council: 'council', region_id: r.id, customer_type_id: t.id, delivery_address: 'address')
    p = Publication.create!(name: 'Fema')
    StandingOrder.create!(customer_id: c.id, publication_id: p.id, num_copies: 10)
    visit(customers_index)
    puts page.html

    expect(page).to have_css("#customer-#{c.id}")
    within("#customer-#{c.id}") do
      expect(page).to have_css("form.new_standing_order")
    end
  end

  scenario "Create a Standing Order using the form" do
    c = Customer.create!(name: 'name', council: 'council')
    p = Publication.make
    visit(customers_index)

    #find("#customer-#{c.id} .standing-orders div.frame>a:first").click # show the form

    within("#customer-#{c.id} form.new_standing_order") do
      fill_in('Qty', :with => '150')
      fill_in('Comment', :with => 'Some comment')
      click_button('Create Standing Order')
    end

    expect(StandingOrder.count).to eq(1)
    so = StandingOrder.first
    expect(so.customer_id).to eq(c.id)
    expect(so.publication_id).to eq(p.id)
    expect(so.num_copies).to eq(150)
    expect(so.comments).to eq('Some comment')
  end
end
