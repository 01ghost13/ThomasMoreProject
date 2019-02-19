class AddBelongsToQuestionResult < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :question_results, :gaze_trace_result
  end
end
