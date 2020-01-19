class RemoveModeFromClients < ActiveRecord::Migration[5.2]
  def change
    remove_belongs_to :clients, :modes

    drop_table :modes, if_exists: true do |t|
      t.string :name
      t.timestamps
    end
  end
end
