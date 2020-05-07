class CreateTestAvailabilities < ActiveRecord::Migration[5.2]
  def change
    create_table :test_availabilities do |t|
      t.belongs_to :test, foreign_key: true
      t.belongs_to :user, foreign_key: true
      t.boolean :available, default: false, null: false

      t.timestamps
    end

    add_index :test_availabilities, %i[test_id user_id], unique: true, name: 'unique_test_roles'
  end
end
