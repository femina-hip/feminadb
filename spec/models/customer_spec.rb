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
        customer = build_customer('council', ' name')
        customer.valid?
        expect(customer.name).to eq('name')
      end

      it 'should strip spaces from end of customer name' do
        customer = build_customer('council', 'name ')
        customer.valid?
        expect(customer.name).to eq('name')
      end

      it 'should strip spaces from both sides of customer name' do
        customer = build_customer('council', ' name ')
        customer.valid?
        expect(customer.name).to eq('name')
      end

      it 'should strip spaces from council' do
        customer = build_customer(' council ', 'name')
        customer.valid?
        expect(customer.council).to eq('council')
      end

      it 'should strip spaces from delivery_address' do
        customer = build_customer('council', 'name', :delivery_address => ' delivery_address ')
        customer.valid?
        expect(customer.delivery_address).to eq('delivery_address')
      end
    end

    describe('fuzzy_find') do
      it 'should find an exact match' do
        customer = create_customer!('council', 'name')
        found = Customer.fuzzy_find(@region.id, 'name')
        expect(found.count).to eq(1)
      end

      it 'should find a match off by one character' do
        customer = create_customer!('council', 'name')
        found = Customer.fuzzy_find(@region.id, 'nam')
        expect(found.count).to eq(1)
      end

      it 'should find a two-word match' do
        customer = create_customer!('council', 'foo bar')
        found = Customer.fuzzy_find(@region.id, 'foo baz')
        expect(found.count).to eq(1)
      end

      it 'should not match a completely different string' do
        customer = create_customer!('council', 'name')
        found = Customer.fuzzy_find(@region.id, 'somewhere')
        expect(found.count).to eq(0)
      end

      it 'should return name and council without a DB hit' do
        customer = create_customer!('council', 'name')
        Customer.connection.execute('DELETE FROM customers')
        found = Customer.fuzzy_find(@region.id, 'name')
        expect(found.count).to eq(1)
        raw_result = found.first
        expect(raw_result.primary_key.to_i).to eq(customer.id)
        expect(raw_result.stored(:council)).to eq('council')
        expect(raw_result.stored(:name)).to eq('name')
      end

      it 'should match uppercase names' do
        customer = create_customer!('council', 'NAME')
        found = Customer.fuzzy_find(@region.id, 'name')
        expect(found.count).to eq(1)
      end
    end

    def build_customer(council, name, options = {})
      Customer.new({
        region_id: @region.id,
        customer_type_id: @customer_type.id,
        council: council,
        name: name,
        delivery_address: 'delivery address'
      }.merge(options))
    end

    def create_customer!(council, name, options = {})
      customer = build_customer(council, name, options)

      customer.save!
      Customer.reindex(:include => [ { :region => :delivery_method }, :type ])

      customer
    end
  end
end
