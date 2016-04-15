class AddOrganisationAddressToAdministrators < ActiveRecord::Migration
  def change
    add_column :administrators, :organisation_address, :string
    add_index :administrators, :organisation_address, :unique => true
  end
end
