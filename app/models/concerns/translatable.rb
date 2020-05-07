module Translatable
  extend ActiveSupport::Concern

  included do

    has_many :translated_columns, as: :translatable

    class << self

      def define_translatable_columns(column_names)
        column_names.each do |column_name|
          define_method column_name do
            return super() if language_id.blank?

            translated_attr_name = :"@#{column_name}_translated"

            translation_cache = instance_variable_get(translated_attr_name)
            return translation_cache if translation_cache.present?

            translation = translated_columns.find do |translation|
              translation.language_id == language_id && translation.target_column == column_name.to_s
            end

            translation = translation.try(:translation) || super()

            instance_variable_set(translated_attr_name, translation)
          end
        end
      end

    end
  end

  class << self
    def wrap_language(array, language_id)
      return array if array.blank?

      if array.is_a? Enumerable
        array.each do |el|
          el.language_id = language_id
        end
      else
        array.language_id = language_id
      end

      array
    end
  end
end
