require 'test_helper'

class InfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  fixtures :infos
  test "Empty fields" do
    inf = Info.new
    assert inf.invalid?
    assert inf.errors[:name].any?
    assert inf.errors[:last_name].any?
    assert inf.errors[:password_digest].any?
    #assert inf.errors[:phone].any?
    assert !inf.errors[:is_mail_confirmed].any?
    assert inf.errors[:mail].any?
  end
  test "Uniq mail" do
    inf = Info.new(name: 'SomeName', last_name: 'SomeLastNAme', password: '456789123', phone: '789456123', mail: infos(:infoAdm))
    assert inf.invalid?
    assert inf.errors[:mail].any?
  end
end
