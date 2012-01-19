# encoding: utf-8
require 'mongoid'
require 'mongoid/translate'
require 'mongoid/translation'

module Mongoid
  module Translate
    autoload :Slug,          'mongoid/translate/slug'
  end

  module Translation
    autoload :Slug,          'mongoid/translation/slug'
  end
end
