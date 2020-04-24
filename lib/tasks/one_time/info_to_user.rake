namespace :one_time do
  task info_to_user: :environment do

    Info.all.in_batches of: 200 do |relation|
      relation.each do |record|
        begin
          p "#{record.id} #{record.mail}"
          role = if record.mentor?
                   :mentor
                 elsif record.super_administrator?
                   :super_admin
                 elsif record.administrator?
                   :local_admin
                 end

          u = User.create!(
              email: record.mail,
              password: record.password_digest,
              role: role,
              userable: record.administrator || record.mentor,
              confirmed_at: Date.current
          )
          u.reload.update_column(:encrypted_password, record.password_digest)
        rescue StandardError => e
          p "#{e}\n#{e.message}\nInfo:#{record.id}"
          raise e
        end
      end
    end

    Client.all.in_batches of: 200 do |relation|
      relation.each do |client|
        begin
          fake_email = "#{client.code_name.gsub(' ','')}@ait.com"
          p "#{client.id} #{fake_email}"
          u = User.create!(
              email: "client_#{client.id}@ait.com",
              password: client.password_digest,
              role: :client,
              userable: client,
              confirmed_at: Date.current
          )
          u.reload.update_columns(encrypted_password: client.password_digest)
        rescue StandardError => e
          p "#{e}\n#{e.message}\nClient:#{client.id}"
          raise e
        end
      end
    end
  end

  task rollback_users: :environment do
    User.all.each(&:destroy)
  end
end
