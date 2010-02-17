class AddCustomerTypeAbbrAndInsertTypes < ActiveRecord::Migration
  def self.up
    # At this point in development, we only have Secondary School and Unknown
    CustomerType.enumeration_model_updates_permitted = true

    unknown_id = CustomerType['Unknown'].id

    Customer.find(:all, [ 'customer_type_id <> ?', CustomerType['Secondary School'].id ]) do |c|
      c.customer_type_id = unknown_id
      c.save!
    end

    ['NGO', 'Business', 'College', 'Government',
     'Institution', 'Religious', 'Youth Group'].each do |name|
      CustomerType[name].destroy if not CustomerType[name].nil?
    end

    add_column :customer_types, :description, :string, :null => false, :default => ''
    add_column :customer_types, :category, :string, :null => false, :default => 'Unknown'
    CustomerType.reset_column_information
    CustomerType.enumeration_model_updates_permitted = true

    CustomerType.create(:name => 'CBO', :description => 'Community-Based Organization', :category => 'Organization')
    CustomerType.create(:name => 'EM', :description => 'Embassy', :category => 'Organization')
    CustomerType.create(:name => 'INGO', :description => 'International Non-Governmental Organization', :category => 'Organization')
    CustomerType.create(:name => 'NGO', :description => 'Non-Governmental Organization (Local)', :category => 'Organization')
    CustomerType.create(:name => 'UN', :description => 'UN Agency', :category => 'Organization')
    CustomerType.create(:name => 'VSO', :description => 'Volunteer Sending Organization', :category => 'Organization')
    CustomerType.create(:name => 'GM', :description => 'Government Ministry', :category => 'Government')
    CustomerType.create(:name => 'GEI', :description => 'Government Educational Institution', :category => 'Government')
    CustomerType.create(:name => 'GHI', :description => 'Government Health Institution', :category => 'Government')
    CustomerType.create(:name => 'LGA', :description => 'Local Government Authority', :category => 'Government')
    CustomerType.create(:name => 'IC', :description => 'International Corporation', :category => 'Business')
    CustomerType.create(:name => 'LC', :description => 'Local Corporation', :category => 'Business')
    CustomerType.create(:name => 'NC', :description => 'National Corporation', :category => 'Business')
    CustomerType.create(:name => 'PHI', :description => 'Private Health Institution', :category => 'Business')
    CustomerType.create(:name => 'GSS', :description => 'Government Secondary School', :category => 'Education')
    CustomerType.create(:name => 'PSS', :description => 'Private Secondary School', :category => 'Education')
    CustomerType.create(:name => 'GPS', :description => 'Government Primary School', :category => 'Education')
    CustomerType.create(:name => 'PPS', :description => 'Private Primary School', :category => 'Education')

    if not CustomerType['Secondary School'].nil?
      CustomerType.create(:name => 'USS', :description => 'DO NOT USE: switch to GSS or PSS', :category => 'Education')
      Customer.find_all_by_customer_type_id(CustomerType['Secondary School'].id).each do |c|
        c.customer_type_id = CustomerType['USS'].id
        c.save!
      end
      CustomerType['Secondary School'].destroy
    end

    if not CustomerType['Unknown'].nil?
      CustomerType.create(:name => 'U', :description => 'Unknown')
      Customer.find_all_by_customer_type_id(CustomerType['Unknown'].id).each do |c|
        c.customer_type_id = CustomerType['U'].id
        c.save!
      end
      CustomerType['Unknown'].destroy
    end
  end

  def self.down
    CustomerType.enumeration_model_updates_permitted = true

    ss = CustomerType.create :name => 'Secondary School'
    u = CustomerType.create :name => 'Unknown'

    CustomerType.find_all_by_category('Education') do |ct|
      Customer.find_all_by_customer_type_id(ct.it) do |c|
        c.customer_type_id = ss.id
        c.save!
      end
    end

    Customer.find(:all, [ 'customer_type_id <> ?', ss.id ]) do |c|
      c.customer_type_id = u.id
      c.save!
    end

    CustomerType['CBO'].destroy
    CustomerType['EM'].destroy
    CustomerType['INGO'].destroy
    CustomerType['NGO'].destroy
    CustomerType['UN'].destroy
    CustomerType['VSO'].destroy
    CustomerType['GM'].destroy
    CustomerType['GEI'].destroy
    CustomerType['GHI'].destroy
    CustomerType['LGA'].destroy
    CustomerType['IC'].destroy
    CustomerType['LC'].destroy
    CustomerType['NC'].destroy
    CustomerType['PHI'].destroy
    CustomerType['GSS'].destroy
    CustomerType['PSS'].destroy
    CustomerType['GPS'].destroy
    CustomerType['PPS'].destroy
    CustomerType['USS'].destroy
    CustomerType['U'].destroy

    remove_column :customer_types, :description
    remove_column :customer_types, :category
    CustomerType.reset_column_information
    CustomerType.enumeration_model_updates_permitted = true

    ['NGO', 'Business', 'College', 'Government',
     'Institution', 'Religious', 'Youth Group'].each do |name|
      CustomerType.create :name => name
    end
  end
end
