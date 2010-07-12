require 'machinist/active_record'

Customer.blueprint do
  name { 'Customer' }
  district { 'District' }
  type
  region
  delivery_method
end

CustomerType.blueprint do
  name { 'CT' }
  description { 'Customer Type' }
  category { 'Category' }
end

DeliveryMethod.blueprint do
  name { 'Delivery Method' }
  abbreviation { 'DM' }
  warehouse
end

Publication.blueprint do
  name { 'Publication' }
  tracks_standing_orders { true }
  pr_material { false }
end

Region.blueprint do
  name { 'Region' }
end

Role.blueprint do
  name { 'role' }
end

User.blueprint do
  login { 'login' }
  email { 'login@email.com' }
  password { 'password' }
  password_confirmation { 'password' }
end

Warehouse.blueprint do
  name { 'Warehouse' }
end
