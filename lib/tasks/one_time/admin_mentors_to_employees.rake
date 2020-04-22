namespace :one_time do
  task admin_mentors_to_employees: :environment do

    Administrator.all.in_batches of: 200 do |relation|
      relation.each do |record|
        user = record.user
        info = record.info

        e = Employee.create!(
          last_name: info.last_name,
          name: info.name,
          phone: info.phone,
          organisation: record.organisation,
          organisation_address: record.organisation_address,
        )
        user.update(userable: e.reload)

        record.mentors.each do |record_mentor|
          user_mentor = record_mentor.user
          info_mentor = record_mentor.info

          e_mentor = Employee.create!(
            last_name: info_mentor.last_name,
            name: info_mentor.name,
            phone: info_mentor.phone,
            employee_id: e.id,
          )

          user_mentor.update(userable: e_mentor.reload)

          record_mentor.clients.each do |client|
            client.update_column('employee_id', e_mentor.id)
          end
        end
      end
    end
  end

  task rollback_employees: :environment do
    Employee.all.each(&:destroy)
    Rake::Task['one_time:rollback_users'].invoke
    Rake::Task['one_time:info_to_user'].invoke
  end
end
