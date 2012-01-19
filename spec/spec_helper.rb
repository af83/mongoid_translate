# encoding: utf-8
path = File.expand_path(File.dirname(__FILE__) + '/../lib/')
$LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)

require 'mongoid_translate'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db('mongoid_translate_spec')
end

RSpec.configure do |config|
  # Require spec models ; order does matter
  Dir[File.dirname(__FILE__) + "/models/*.rb"].each {|file| require file }
  Dir[File.dirname(__FILE__) + "/models/bar/*.rb"].each {|file| require file }
  Dir[File.dirname(__FILE__) + "/models/**/*.rb"].each {|file| require file }

  config.after :each do
    Mongoid.master.collections.reject { |c| c.name =~ /^system\./ }.each(&:drop)
  end
end
