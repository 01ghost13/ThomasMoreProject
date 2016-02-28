class Info < ActiveRecord::Base
  has_one :administrator
  has_one :tutor
end
