class RemoveSchoolingModel < ActiveRecord::Migration[5.2]
  def up
    remove_belongs_to :students, :schooling
    remove_belongs_to :result_of_tests, :schooling
    drop_table :schoolings
  end

  def down
    create_table :schoolings do |t|
        t.string :name

        t.timestamps null: false
    end
    add_belongs_to :students, :schoolings, index: true, foreign_key: true
    add_belongs_to :result_of_tests, :schoolings, index: true, foreign_key: true
  end
end
