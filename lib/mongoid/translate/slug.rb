# encoding: utf-8
module Mongoid
  module Translate
    module Slug
      extend ::ActiveSupport::Concern

      included do
        scope :by_slug, lambda {|slug| where('translations.slug' => slug )}
        index 'translations.slug'
      end

      module InstanceMethods

        def to_slug
          locale = languages.include?(I18n.locale) ? I18n.locale : main_language
          translations.where(language: locale).one.slug
        end
      end

      module ClassMethods
        attr_accessor :slugged

        def slug_field(slug_field)
          self.slugged = slug_field
        end

      end
    end
  end
end
