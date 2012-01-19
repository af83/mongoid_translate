# encoding: utf-8

require 'active_support/concern'
require 'mongoid'

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

  module Translation
    module Slug
      extend ::ActiveSupport::Concern

      included do
        field :slug, type: String
        after_validation :set_slug
      end

      module InstanceMethods
        def set_slug
          if self.slug.blank? && slugged_field.present?
            if translation_parent_class.send(:by_slug, slugged).one
              self.slug = slugged_with_token
            else
              self.slug = slugged
            end
          end
        end

        private

        def slugged_field
          @slugged_field ||= self.send(translation_parent_class.slugged)
        end

        def slugged
          @slugged ||= slugged_field.parameterize.blank? ? slugged_field : slugged_field.parameterize
        end

        def slugged_with_token
          @slugged_with_token ||= [slugged, generate_token].join('-')
        end

        def translation_parent_class
          self.class.to_s.gsub('Translation::', '').constantize
        end

        def translation_parent
          self.send(self.class.to_s.gsub(/^.*::/, '').underscore)
        end

        def generate_token
          SecureRandom.base64(4).tr('+/=', '-_ ').strip.delete("\n")
        end
      end
    end
  end
end
