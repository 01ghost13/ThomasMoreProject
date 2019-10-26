# == Schema Information
#
# Table name: administrators
#
#  id                   :integer          not null, primary key
#  is_super             :boolean
#  organisation         :string
#  info_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_address :string
#

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
  test "Adding ladmin" do
    adm = Administrator.new(info_id: infos(:infoAdm).id, organisation: 'TestOrg', is_super: false)
    assert adm.valid?, "#{adm.errors[:info_id]}, #{adm.errors[:is_super]} : #{adm.is_super}, #{adm.errors[:organisation]}"
    assert adm.errors[:info_id].empty?
    assert adm.errors[:is_super].empty?
    assert adm.errors[:organisation].empty?
  end
end
