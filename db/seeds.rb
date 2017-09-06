#Creating of administrator
admInfo = Info.create(name: 'Jan', last_name: 'Dekelver', password: '12345', phone: '89012345678', mail: 'test@mail.com')
admInfo.is_mail_confirmed = true
admInfo.save
superAdm = Administrator.create(info_id: admInfo.id, organisation: 'Administrator', organisation_address: "Some address")
superAdm.is_super = true
superAdm.save
#Creating of modes
blind_mode = Mode.create(name: 'Blind')
one_click_mode = Mode.create(name: 'One click mode')
#Schooling
example_of_schooling = Schooling.create(name: 'School')
another_example_of_schooling = Schooling.create(name: 'University')

if Rails.env.production?
  ##############################################
  #PRODUCTION SEED
  ##############################################
#Interests
  interests = []
  ['Semi-industrial work',
   'Housework',
   'Food preparation work',
   'Administrative work',
   'Service work',
   'Textile work forms',
   'Pet care',
   'Gardening',
   'Creative work',
   'Care & Wellbeing',
   'Art and craft',
   'Customizable work'
  ].each do |t|
    interests << Interest.create(name: t)
  end

#Tests
  test = Test.create(name: 'Labour test',description:'Test for finding an interests', version: '0.01')
#Pictures
  picture_names = ['Semi-industrieelwerk',
                   'Huishoudelijkwerk',
                   'Voedselbereidendwerk',
                   'Administratiefwerk',
                   'Dienstverlenendwerk',
                   'Textielewerkvormen',
                   'Dierenverzorging',
                   'Tuinieren',
                   'Creatiefwerk',
                   'Zorg&Welzijn',
                   'Ambachtelijkwerk',
                   'Klantgerichtwerk',
  ]
  titles = ['Sort products', 'Pack batteries', 'Seal bags', 'Fold boxes', 'Stick stickers', 'Clean windows',
            'Fold laundry', 'Floor mop', 'Clear the tables', 'Vacuum', 'Knead dough', 'Make cookies', 'Make soup',
            'Make coffee', 'Peel patatoes', 'Laminate', 'Work with the computer', 'Work with a calculator', 'Coping',
            'Shred documents', 'Assist with loading and unloading', 'Deliver mail', 'Collect paper',
            'Clean garbage containers', 'Sort empty bottles', 'Embroider tablecloth', 'Crochet', 'Smyrna', 'Macrame',
            'Sewing', 'Feed animals', 'Pick up eggs', 'Give water to the animals', 'Brush animals',
            'Put animals in the stable', 'Cultivate plants and flowers', 'Pick tomatoes', '  Weed ', 'Mow grass', 'Rake leaves',
            'Model', 'Draw and paint', 'String beads', 'Sculpture', 'Paint silk', 'Walk with a wheelchair user',
            'Care for people', 'Change toddlers', 'Read stories', 'Help people dress up', 'Poor candles', 'Pottery',
            'Process wood', 'Cast sculptures', 'Create paper', 'Deliver orders', 'Work in a store', 'Give information',
            'Phone', 'Give change money']
  pictures = []
  (0..11).each do |i|
    (0..4).each do |j|

      file = File.open("app/Pictures/#{picture_names[i]}/#{picture_names[i]}_#{j+1}.jpg")

      pic = Picture.create!(description: titles[i*5 + j],
                            image: file)
      pictures << pic
      file.close
      q = Question.create!(test_id: test.id, is_tutorial: false, picture_id: pic.id, number: i*5 + j + 1)
      pic.picture_interests << PictureInterest.new(interest_id: interests[i].id, earned_points: 1)
    end
  end
else
  ##############################################
  #DEVELOPMENT SEED
  ##############################################
#Creating of seed models...
#LAdm
  LadmInfo = Info.create(name: 'LocalAdm', last_name: 'TestLastNamr', password: '020695', phone: '89023853401', mail: 'another@mail.com')
  LadmInfo.is_mail_confirmed = true
  LadmInfo.save
  lAdm = Administrator.create(info_id: LadmInfo.id, organisation: 'Some organisation', organisation_address: "Other address")
#Tutors
  tutorInfo = Info.create(name: 'Dmitry', last_name: 'Skvaznikov', password: '020695', phone: '89023853401', mail: 'some@mail.com')
  tutorInfo.is_mail_confirmed = true
  tutorInfo.save
  first_tutor = Tutor.create(administrator_id: lAdm.id, info_id: tutorInfo.id)

#Students
  first_student = Student.create(tutor_id: first_tutor.id, code_name: '01ghost13', gender: 2, is_active: true, password: '020695', schooling_id: example_of_schooling.id, is_current_in_school: true)


#Interests
  interests = []
  ["Cooking","Factory","HardWork","Animal","Magic","EtcInterests"].each do |t|
    interests << Interest.create(name: t)
  end
#Pictures
  file = File.open('app/assets/images/Semiindustrieelwerk1.jpg')

  pic1 = Picture.create(description: "Something for pic1",
                        image: file)
  file.close

  file = File.open('app/assets/images/Semiindustrieelwerk2.jpg')
  pic2 = Picture.create(description: "Something for pic2",
                        image: file)
  file.close

  file = File.open('app/assets/images/Semiindustrieelwerk3.jpg')
  pic3 = Picture.create(description: "Something for pic3",
                        image: file)
  file.close

  file = File.open('app/assets/images/Semiindustrieelwerk4.jpg')
  pic4 = Picture.create(description: "Something for pic4",
                        image: file)
  file.close

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
end