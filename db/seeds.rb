# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
##############################################################################################################################################
#Creating of administrator
admInfo = Info.create(name: 'Jan', last_name: 'Dekelver', password: '12345', phone: '89012345678', mail: 'test@mail.com', is_mail_confirmed: true)
superAdm = Administrator.create(info_id: admInfo.id, organisation: 'Administrator', is_super: true, organisation_address: "Some address")
superAdm.is_super = true
superAdm.save
#Creating of modes
blind_mode = Mode.create(name: 'Blind')
one_click_mode = Mode.create(name: 'One click mode')
#Schooling
example_of_schooling = Schooling.create(name: 'School')
another_example_of_schooling = Schooling.create(name: 'University')
#Creating of seed models...
#LAdm
LadmInfo = Info.create(name: 'LocalAdm', last_name: 'TestLastNamr', password: '020695', phone: '89023853401', mail: 'another@mail.com', is_mail_confirmed: true)
lAdm = Administrator.create(info_id: LadmInfo.id, organisation: 'Some organisation', organisation_address: "Other address")
#Tutors
tutorInfo = Info.create(name: 'Dmitry', last_name: 'Skvaznikov', password: '020695', phone: '89023853401', mail: 'some@mail.com', is_mail_confirmed: true)
first_tutor = Tutor.create(administrator_id: lAdm.id, info_id: tutorInfo.id)

#Students
first_student = Student.create(tutor_id: first_tutor.id, code_name: '01ghost13', gender: 2, is_active: true, password: '020695', schooling_id: example_of_schooling.id, is_current_in_school: true)


#Interests
interests = []
["Cooking","Factory","HardWork","Animal","Magic","EtcInterests"].each do |t|
  interests << Interest.create(name: t)
end
#Pictures
pic1 = Picture.create(description: "Something for pic1", path: "Semiindustrieelwerk1.jpg")
pic2 = Picture.create(description: "Something for pic2", path: "Semiindustrieelwerk2.jpg")
pic3 = Picture.create(description: "Something for pic3", path: "Semiindustrieelwerk3.jpg")
pic4 = Picture.create(description: "Something for pic4", path: "Semiindustrieelwerk4.jpg")

#Tests
test = Test.create(name: "First test",description:"This is the first test", version: "0.01")
#Questions
q1 = Question.create(test_id: test.id, is_tutorial: true, picture_id: pic1.id, number: 1)
q2 = Question.create(test_id: test.id, is_tutorial: false, picture_id: pic2.id, number: 2)
q3 = Question.create(test_id: test.id, is_tutorial: false, picture_id: pic3.id, number: 3)
q4 = Question.create(test_id: test.id, is_tutorial: false, picture_id: pic4.id, number: 4)

#Linking pic with interests
interests[2..4].each do |t|
  pic1.picture_interests << PictureInterest.new(interest_id: t.id, earned_points: 1)
end
pic2.picture_interests << PictureInterest.new(interest_id: interests[0].id, earned_points: 2)
interests[1..3].each do |t|
  pic3.picture_interests << PictureInterest.new(interest_id: t.id, earned_points: 3)
end
