# encoding: utf-8
module Mongoid
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
