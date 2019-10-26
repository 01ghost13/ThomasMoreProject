class RemoveTutorialOpt < ActiveRecord::Migration[5.2]
  def change
    remove_column :questions, :is_tutorial, :boolean, default: false
  end
end
