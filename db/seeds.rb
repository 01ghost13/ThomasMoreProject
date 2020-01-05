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
