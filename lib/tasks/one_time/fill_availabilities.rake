namespace :one_time do
  task fill_availabilities: :environment do
    tests = Test.all.select(:id, :name)
    users = User.all_local_admins.includes(:test_availabilities)

    users.each do |user|
      tests.each do |test|
        user.test_availabilities.create(test_id: test.id, available: true)
      end
    end
  end
end
