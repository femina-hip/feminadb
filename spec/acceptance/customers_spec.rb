require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit standing orders from customer page", %q{
  In order to create and edit standing orders
  As a user with edit-orders privilege
  I want to use an edit standing orders form on the customers page
}, js: true do

  background do
    User.create!(email: 'order-editor@example.org', roles: 'edit-orders')
    login('order-editor@example.org')
  end
  
  scenario "Edit a standing order" do
    d = DeliveryMethod.create!(abbreviation: 'DM', name: 'delivery_method')
    r = Region.create!(name: 'region', delivery_method_id: d.id)
    t = CustomerType.create!(name: 'type', description: 'customer type')
    c = Customer.create!(name: 'name', council: 'council', region_id: r.id, customer_type_id: t.id, delivery_address: 'address')
    p = Publication.create!(name: 'Fema', tracks_standing_orders: true, pr_material: false)
    StandingOrder.create!(customer_id: c.id, publication_id: p.id, num_copies: 10)
    Customer.reindex
    visit(customers_index)

    expect(page).to have_css("#customer-#{c.id}")
    within("#customer-#{c.id}") { click_on('10') }

    expect(page).to have_css('.modal form', wait: 10000)

    within('.modal form') do
      fill_in('# Copies', with: '50')
      fill_in('Comments', with: 'edited automatically')
      click_button('Save')
    end
    expect(page).not_to have_css('.modal form')

    expect(page.find("#customer-#{c.id} td.standing-orders")).to have_text('50')
    # aaaand make sure it survives page refresh
    visit(customers_index)
    expect(page.find("#customer-#{c.id} td.standing-orders")).to have_text('50')
  end

  scenario "Create a Standing Order using the form" do
    d = DeliveryMethod.create!(abbreviation: 'DM', name: 'delivery_method')
    r = Region.create!(name: 'region', delivery_method_id: d.id)
    t = CustomerType.create!(name: 'type', description: 'customer type')
    c = Customer.create!(name: 'name', council: 'council', region_id: r.id, customer_type_id: t.id, delivery_address: 'address')
    p = Publication.create!(name: 'Fema', tracks_standing_orders: true, pr_material: false)
    Customer.reindex
    visit(customers_index)

    expect(page).to have_css("#customer-#{c.id}")
    within("#customer-#{c.id}") { click_on('…') }

    within('.modal form') do
      fill_in('# Copies', with: '50')
      fill_in('Comments', with: 'created automatically')
      click_button('Create New Standing Order')
    end
    expect(page).not_to have_css('.modal form')

    expect(page.find("#customer-#{c.id} td.standing-orders")).to have_text('50')
    # aaaand make sure it survives page refresh
    visit(customers_index)
    expect(page.find("#customer-#{c.id} td.standing-orders")).to have_text('50')
  end
end
