require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit standing orders from customer page", %q{
  In order to create and edit standing orders
  As a user with edit-orders privilege
  I want to use an edit standing orders form on the customers page
} do

  background do
    r1 = Role.make(:name => 'edit-orders')
    r2 = Role.make(:name => 'view')
    User.make(:login => 'order-editor', :password => 'password', :roles => [r1, r2])
    login('order-editor', 'password')
  end
  
  scenario "Get an 'edit standing order' form when there's a standing order" do
    c = Customer.make
    Publication.make
    visit(customers_index)

    page.should(have_css("#customer-#{c.id}"))
    within("#customer-#{c.id}") do
      page.should(have_css("form.new_standing_order"))
    end
  end

  scenario "Create a Standing Order using the form" do
    c = Customer.make
    p = Publication.make
    visit(customers_index)

    #find("#customer-#{c.id} .standing-orders div.frame>a:first").click # show the form

    within("#customer-#{c.id} form.new_standing_order") do
      fill_in('Qty', :with => '150')
      fill_in('Comment', :with => 'Some comment')
      click_button('Create Standing Order')
    end

    StandingOrder.count.should == 1
    so = StandingOrder.first
    so.customer_id.should == c.id
    so.publication_id.should == p.id
    so.num_copies.should == 150
    so.comments.should == 'Some comment'
  end
end
