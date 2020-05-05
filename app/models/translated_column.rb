# == Schema Information
#
# Table name: translated_columns
#
#  id                :bigint           not null, primary key
#  target_column     :string           not null
#  translatable_type :string
#  translation       :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  language_id       :bigint           not null
#  translatable_id   :bigint
#

class TranslatedColumn < ActiveRecord::Base

  belongs_to :translatable, polymorphic: true
  belongs_to :language

  def field_name
    "#{translatable_type.downcase.pluralize}.#{translatable_id}.#{target_column}"
  end
end
