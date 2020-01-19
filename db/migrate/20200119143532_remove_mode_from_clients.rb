class RemoveModeFromClients < ActiveRecord::Migration[5.2]
  def up
    remove_belongs_to :clients, :mode

    drop_table :modes, if_exists: true
  end

  def down
    add_belongs_to :clients, :mode, index: true, foreign_key: true

    create_table :modes, if_not_exists: true do |t|
      t.string :name
      t.timestamps
    end
  end
end
