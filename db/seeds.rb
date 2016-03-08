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
#Creating of modes
blind_mode = Mode.create(name: 'Blind')
one_click_mode = Mode.create(name: 'One click mode')
#Schooling
example_of_schooling = Schooling.create(name: 'School')
another_example_of_schooling = Schooling.create(name: 'University')
#Creating of seed models...
#LAdm
LadmInfo = Info.create(name: 'LocalAdm', last_name: 'TestLastNamr', password_digest: '020695', phone: '89023853401', mail: 'another@mail.com', is_mail_confirmed: true)
lAdm = Administrator.create(info_id: LadmInfo.id, organisation: 'Some organisation', is_super: false)
#Tutors
tutorInfo = Info.create(name: 'Dmitry', last_name: 'Skvaznikov', password_digest: '020695', phone: '89023853401', mail: 'some@mail.com', is_mail_confirmed: true)
first_tutor = Tutor.create(administrator_id: lAdm.id, info_id: tutorInfo.id)

#Students
first_student = Student.create(tutor_id: first_tutor.id, code_name: '01ghost13', gender: 2, is_active: true, password_digest: '020695', schooling_id: example_of_schooling.id, is_current_in_school: true)

#Tests