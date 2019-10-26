namespace :test do
  desc "fills test from directory vendor/assets/images"

  task fill_new_test: :environment do
    ActiveRecord::Base.transaction do
      test = Test.create!(name: 'Тестирование', description: 'последняя версия тестирования на профинтерес', version: '0.01')
      i = 1
      Rails.root.join('vendor', 'assets', 'images').children.each do |path|
        puts "Adding pics from #{path}"
        interest = Interest.create!(name: path.basename.to_s.length > 24 ? path.basename.to_s[0, 21] + '...' : path.basename.to_s)

        pictures = path.children
        pictures.each do |picture_path|
          file = File.open(picture_path)
          pic = Picture.new description: 'Описание изображения',
                                picture_interests_attributes: [{
                                    interest_id: interest.id,
                                    earned_points: 1
                                }]
          pic.image.attach io: file,
                           filename: path.basename.to_s,
                           content_type: 'image/jpg'
          pic.save!
          test.questions.build(picture_id: pic.id, number: i)

          i += 1
        end
      end
      test.save!
    end
  end

end
