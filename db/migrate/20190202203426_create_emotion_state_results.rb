class CreateEmotionStateResults < ActiveRecord::Migration[5.2]
  def change
    create_table :emotion_state_results do |t|
      t.json :states, default: []

      t.timestamps
    end

    add_belongs_to :question_results, :emotion_state_result
  end
end
