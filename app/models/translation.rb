# == Schema Information
#
# Table name: translations
#
#  id           :bigint           not null, primary key
#  field        :string           not null
#  value        :string           not null
#  languages_id :bigint           not null
#

class Translation < ActiveRecord::Base
end
