# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'mongoid/translate/version'

Gem::Specification.new do |s|
  s.name         = "mongoid_translate"
  s.version      = Mongoid::Translate::VERSION
  s.authors      = ["chatgris", "klacointe"]
  s.email        = "jboyer@af83.com"
  s.homepage     = "https://github.com/AF83/mongoid_translate"
  s.summary      = "Translate mongoid models."
  s.description  = "Translate mongoid models."
  s.files        = `git ls-files lib MIT-LICENSE README.md`.split("\n")
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.add_dependency "activesupport",     "~>3.1"
  s.add_dependency "mongoid",           "~>2.3"
  s.add_dependency "bson_ext",          "~>1.4"
  s.add_development_dependency "rspec", "~>2.6"
end
