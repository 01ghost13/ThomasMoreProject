class CreateQuestionResults < ActiveRecord::Migration
  def change
    create_table :question_results do |t|
      t.integer :number #Number of Q
      t.datetime :start #Start of choosing answer
      t.datetime :end #End
      t.boolean :was_rewrited #Was reentered
      t.belongs_to :result_of_test, index: true, foreign_key: true
      t.integer :was_checked #Was Thumbs up or not
      
      t.timestamps null: false
    end
  end
end
