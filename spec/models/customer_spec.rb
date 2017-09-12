require File.dirname(__FILE__) + '/../spec_helper'

describe(Customer) do
  describe('starting from a clean database') do
    before(:all) do
      Region.delete_all
      CustomerType.delete_all
      DeliveryMethod.delete_all
      Customer.delete_all
      Customer.reindex
      @delivery_method = DeliveryMethod.create!(:abbreviation => 'abbr', :name => 'name')
      @region = Region.create!(:name => 'region', :delivery_method_id => @delivery_method.id)
      @customer_type = CustomerType.create!(:name => 'type', :description => 'test type', :category => 'category')
    end

    private

    describe('validation') do
      it 'should strip spaces from beginning of customer name' do
        customer = build_customer('district', ' name')
        customer.valid?
        customer.name.should == 'name'
      end

      it 'should strip spaces from end of customer name' do
        customer = build_customer('district', 'name ')
        customer.valid?
        customer.name.should == 'name'
      end

      it 'should strip spaces from both sides of customer name' do
        customer = build_customer('district', ' name ')
        customer.valid?
        customer.name.should == 'name'
      end

      it 'should strip spaces from district' do
        customer = build_customer(' district ', 'name')
        customer.valid?
        customer.district.should == 'district'
      end

      it 'should strip spaces from deliver_via' do
        customer = build_customer('district', 'name', :deliver_via => ' deliver_via ')
        customer.valid?
        customer.deliver_via.should == 'deliver_via'
      end
    end

    describe('fuzzy_find') do
      it 'should find an exact match' do
        customer = create_customer!('district', 'name')
        found = Customer.fuzzy_find(@region.id, 'district', 'name')
        found.count.should == 1
      end

      it 'should find a match off by one character' do
        customer = create_customer!('district', 'name')
        found = Customer.fuzzy_find(@region.id, 'district', 'nam')
        found.count.should == 1
      end

      it 'should find a two-word match' do
        customer = create_customer!('district', 'foo bar')
        found = Customer.fuzzy_find(@region.id, 'district', 'foo baz')
        found.count.should == 1
      end

      it 'should match a district with a space in the query' do
        customer = create_customer!('district', 'name')
        found = Customer.fuzzy_find(@region.id, 'district ', 'name')
        found.count.should == 1
      end

      it 'should not match a completely different string' do
        customer = create_customer!('district', 'name')
        found = Customer.fuzzy_find(@region.id, 'district', 'somewhere')
        found.count.should == 0
      end

      it 'should not match a deleted Customer' do
        customer = create_customer!('district', 'name')
        customer.soft_delete
        Customer.reindex
        found = Customer.fuzzy_find(@region.id, 'district', 'name')
        found.count.should == 0
      end

      it 'should return region name, name and district without a DB hit' do
        customer = create_customer!('district', 'name')
        found = Customer.fuzzy_find(@region.id, 'district', 'name')
        found.count.should == 1
        raw_result = found.first
        raw_result.primary_key.to_i.should == customer.id
        raw_result.stored(:region).should == @region.name
        raw_result.stored(:district).should == 'district'
        raw_result.stored(:name).should == 'name'
      end

      it 'should match uppercase names' do
        customer = create_customer!('district', 'NAME')
        found = Customer.fuzzy_find(@region.id, 'district', 'NAME')
        found.count.should == 1
      end
    end

    def build_customer(district, name, options = {})
      Customer.new({
        :region_id => @region.id,
        :customer_type_id => @customer_type.id,
        :district => district,
        :name => name
      }.merge(options))
    end

    def create_customer!(district, name, options = {})
      customer = build_customer(district, name, options)

      customer.save!
      Customer.reindex(:include => [ { :region => :delivery_method }, :type ])

      customer
    end
  end
end
