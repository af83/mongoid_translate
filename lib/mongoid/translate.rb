# encoding: utf-8
module Mongoid
  module Translate
    extend ::ActiveSupport::Concern

    # Include translations embeds relation.
    # Add main_language field. [ Symbol ]
    # Add delegate on translated_fields.
    # Add index on translations.language.
    #
    included do
      if self.to_s.include?('::')
        class_name = self.to_s.split('::').insert(-2, "Translation").join('::')
      else
        class_name = "Translation::#{self}"
      end
      field :main_language, type: Symbol, default: lambda { I18n.locale }
      embeds_many :translations, class_name: class_name
      delegate :translated_fields, to: "self.class"
      accepts_nested_attributes_for :translations
      index 'translations.language'
    end

    module InstanceMethods
      # Return list of existing languages
      #
      # @return [ Array ]
      #
      def languages
        translations.map(&:language)
      end

      # Return main translation object
      #
      # @return [ Document ]
      #
      def main_translation
        translations.where(language: main_language).one
      end

    end # InstanceMethods

    module ClassMethods
      attr_accessor :translated_fields

      # creates accessor methods
      #
      def translate(*argv)
        self.translated_fields = *argv

        translated_fields.each do |field|
          # Return field for current locale.
          #
          # Otherwise, fallbacks to main_language.
          #
          # @return [ Object ]
          #
          define_method field do
            locale = languages.include?(I18n.locale) ? I18n.locale : main_language
            translations.where(language: locale).one.try(field)
          end

          # Setter on field for current locale.
          #
          # @return [ Object ]
          #
          define_method "#{field}=" do |arg|
            translations.where(language: I18n.locale).one.try("#{field}=", arg)
          end
        end
      end
    end # ClassMethods
  end # Translate
end # Mongoid
