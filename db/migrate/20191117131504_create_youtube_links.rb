class CreateYoutubeLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :youtube_links do |t|
      t.string :description
      t.string :link

      t.timestamps
    end

    add_reference :picture_interests, :youtube_link
    add_reference :questions, :youtube_link
  end
end
