# encoding: utf-8
require 'mongoid'
require 'mongoid/translate'
require 'mongoid/translation'

module Mongoid
  module Translate
    autoload :Slug,          'mongoid/translate/slug'
  end # Translate

  module Translation
    autoload :Slug,          'mongoid/translation/slug'
  end # Translation
end # Mongoid
