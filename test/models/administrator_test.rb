require 'test_helper'

class AdministratorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :administrators
  fixtures :infos
  test "administrators fields must be non empty" do
    adm = Administrator.new
    assert adm.invalid?
    assert adm.errors[:is_super].any?
    assert adm.errors[:info_id].any?, "Shouldnt be empty"
  end
  test "Uniquenes of adm column" do
    adm = Administrator.new(info_id: infos(:infoAdm).id, organisation: 'TestOrg', is_super: administrators(:admin).is_super)
    assert adm.invalid?
    assert adm.errors[:is_super].any?, "should be uniq"
  end
  test "Uniquenes of info" do
    adm = Administrator.new(info_id: administrators(:admin).info_id, organisation: 'TestOrg', is_super: false)
    assert adm.invalid?
    assert adm.errors[:info_id].any?, "should be uniq"
  end
end
