class AddColumnToClient < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :clients, :employee
  end
end
