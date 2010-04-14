require File.dirname(__FILE__) + '/../spec_helper'

describe(Customer) do
  describe('fuzzy_find') do
    before(:all) do
      Region.delete_all
      CustomerType.delete_all
      DeliveryMethod.delete_all
      Warehouse.delete_all
      Customer.delete_all
      Customer.reindex
      @region = Region.create!(:name => 'region')
      @customer_type = CustomerType.create!(:name => 'type', :description => 'test type', :category => 'category')
      @warehouse = Warehouse.create!(:name => 'name')
      @delivery_method = DeliveryMethod.create!(:abbreviation => 'abbr', :name => 'name', :warehouse_id => @warehouse.id)
    end

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

    private

    def create_customer!(district, name)
      ret = Customer.create!(
        :region_id => @region.id,
        :customer_type_id => @customer_type.id,
        :delivery_method_id => @delivery_method.id,
        :district => district,
        :name => name
      )
      Customer.reindex(:include => [ :region, :type, :delivery_method ])
      ret
    end
  end
end
