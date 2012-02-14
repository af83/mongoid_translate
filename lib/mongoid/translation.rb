# encoding: utf-8
module Mongoid
  module Translation
    extend ::ActiveSupport::Concern

    # Add translated fields to model.
    # Add language field.
    # Add uniqueness validation on language.
    # Set relation on parent.
    #
    included do
      class_name = self.to_s.gsub('Translation::', '')
      name = self.to_s.sub(/^.*::/, '')
      class_name.constantize.translated_fields.each do |field|
        field field
      end
      field :language, type: Symbol, default: lambda { I18n.locale }
      validates_uniqueness_of :language
      embedded_in  name.underscore.to_sym, class_name: class_name
    end

    module InstanceMethods
      # Check if current translation is main_translation.
      #
      # @return [ Boolean ]
      #
      def main_translation?
        parent = self.class.to_s.sub(/^.*::/, '').underscore
        self.send(parent).main_language == self.language
      end
    end # InstanceMethods
  end # Translation
end # Mongoid
