class CreateEmployeTable < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      t.string :organisation
      t.string :phone
      t.string :organisation_address
      t.string :last_name
      t.string :name
      t.belongs_to :employee, default: nil
    end
  end
end
