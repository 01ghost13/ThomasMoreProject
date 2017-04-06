class AddOutdatedToResultOfTests < ActiveRecord::Migration[5.0]
  def change
    add_column :result_of_tests, :is_outdated, :boolean, default: false
  end
end
