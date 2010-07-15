require File.dirname(__FILE__) + '/acceptance_helper'

feature "Edit standing/waiting orders from customer page", %q{
  In order to create and edit standing/waiting orders
  As a user with edit-orders privilege
  I want to use an edit standing/waiting orders form on the customers page
} do

  background do
    r1 = Role.make(:name => 'edit-orders')
    r2 = Role.make(:name => 'view')
    User.make(:login => 'order-editor', :password => 'password', :roles => [r1, r2])
    login('order-editor', 'password')
  end
  
  scenario "Get an 'edit standing/waiting order' form when there's a standing order" do
    c = Customer.make
    Publication.make
    visit(customers_index)

    page.should(have_css("#customer-#{c.id}"))
    within("#customer-#{c.id}") do
      page.should(have_css("form.new_standing_order"))
      page.should(have_css("form.new_waiting_order"))
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

  scenario "Convert a waiting order to a standing order using the form" do
    c = Customer.make
    p = Publication.make
    c.waiting_orders.create!(:publication => p, :num_copies => 10, :request_date => Date.parse('2010-07-14'), :comments => 'blah')
    visit(customers_index)

    #find("#customer-#{c.id} .standing-orders div.frame>a:first").click # show the form

    css = "#customer-#{c.id} input.convert"
    page.should(have_css(css))
    find(css).click

    StandingOrder.count.should == 1
    so = StandingOrder.first
    so.customer_id.should == c.id
    so.publication_id.should == p.id
    so.num_copies.should == 10
    so.comments.should == 'From Waiting Order July 14, 2010: blah'

    WaitingOrder.active.count.should == 0
  end
end

feature "Use tags", %q{
  In order to find customers by arbitrary characteristics
  As a user with edit-customers privilege
  I want to use tags
} do

  background do
    r1 = Role.make(:name => 'edit-customers')
    r2 = Role.make(:name => 'view')
    User.make(:login => 'customer-editor', :password => 'password', :roles => [r1, r2])
    login('customer-editor', 'password')
  end

  scenario "Add a tag and search for it" do
    c1 = Customer.make
    c2 = Customer.make(:name => 'Customer 2', :type => c1.type, :region => c1.region, :delivery_method => c1.delivery_method)

    visit(customer_path(c1))
    within('div.add-tag') do
      fill_in('tag_name', :with => 'foobar')
      click_button('Add Tag')
    end

    within('table.customer-notes') do
      page.should(have_content('TAG_FOOBAR'))
    end

    visit(customers_index('tag:foobar'))
    page.should(have_css("#customer-#{c1.id}"))
    page.should(have_no_css("#customer-#{c2.id}"))
  end
end
