# == Schema Information
#
# Table name: languages
#
#  id   :bigint           not null, primary key
#  name :string           not null
#

class Language < ActiveRecord::Base
  has_many :translations, dependent: :destroy

  validates_presence_of :name
end
