# encoding: utf-8

require 'active_support/concern'
require 'mongoid'

module Mongoid

  module Translate
    extend ::ActiveSupport::Concern

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
    end

    module InstanceMethods
      # Return list of existing languages
      #
      def languages
        translations.map(&:language)
      end

      # Return main translation object
      #
      def main_translation
        translations.where(language: main_language).one
      end

    end

    module ClassMethods
      attr_accessor :translated_fields

      # creates accessor methods
      #
      def translate(*argv)
        self.translated_fields = *argv

        translated_fields.each do |field|
          define_method field do
            locale = languages.include?(I18n.locale) ? I18n.locale : main_language
            translations.where(language: locale).one.try(field)
          end

          define_method "#{field}=" do |arg|
            translations.where(language: I18n.locale).one.try("#{field}=", arg)
          end
        end
      end
    end
  end

  module Translation
    extend ::ActiveSupport::Concern

    included do
      class_name = self.to_s.gsub('Translation::', '')
      name = self.to_s.gsub(/^.*::/, '')
      class_name.constantize.translated_fields.each do |field|
        field field
      end
      field :language, type: Symbol, default: lambda { I18n.locale }
      validates_uniqueness_of :language
      embedded_in  name.underscore.to_sym, class_name: class_name
    end

    module InstanceMethods
      def main_translation?
        parent = self.class.to_s.gsub(/^.*::/, '').underscore
        self.send(parent).main_language == self.language
      end
    end
  end

end
