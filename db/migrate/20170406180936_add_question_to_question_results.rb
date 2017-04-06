class AddQuestionToQuestionResults < ActiveRecord::Migration[5.0]
  def change
    add_reference :question_results, :question, foreign_key: true
  end
end
