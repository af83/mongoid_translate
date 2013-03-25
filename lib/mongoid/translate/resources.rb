# encoding: utf-8
module Mongoid
  module Translate
    module Resources
      extend ActiveSupport::Concern

      included do
        before_filter :build_translations, only: :edit
        before_filter :build_translations_for_new, only: :new
      end

      protected

      def build_translations
        (I18n.available_locales - resource.languages).each do |language|
          resource.translations.build(language: language)
        end
      end

      def build_translations_for_new
        (I18n.available_locales - build_resource.languages).each do |language|
          build_resource.translations.build(language: language)
        end
      end
    end
  end
end
