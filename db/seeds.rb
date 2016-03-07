# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
##############################################################################################################################################
#Creating of administrator
admInfo = Info.create(name: 'Jan', last_name: 'Dekelver', password_digest: '12345', phone: '89012345678', mail: 'test@mail.com', is_mail_confirmed: true)
superAdm = Administrator.create(info_id: admInfo.id, organisation: 'Administrator', is_super: true)
