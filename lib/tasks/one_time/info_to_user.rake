namespace :one_time do
  task info_to_user: :environment do

    Info.all.in_batches of: 200 do |relation|
      relation.each do |record|
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
      end
    end

    Client.all.in_batches of: 200 do |relation|
      relation.each do |client|
        u = User.create!(
            email: "#{client.code_name}@ait.com",
            password: client.password_digest,
            role: :client,
            userable: client,
            confirmed_at: Date.current
        )
        u.reload.update_column(:encrypted_password, client.password_digest)
      end
    end
  end

  task rollback_users: :environment do
    User.all.each(&:destroy)
  end
end
