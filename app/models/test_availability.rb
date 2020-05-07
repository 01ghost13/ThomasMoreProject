# == Schema Information
#
# Table name: test_availabilities
#
#  id         :bigint           not null, primary key
#  available  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  test_id    :bigint
#  user_id    :bigint
#

class TestAvailability < ActiveRecord::Base
  belongs_to :test
  belongs_to :user
end
