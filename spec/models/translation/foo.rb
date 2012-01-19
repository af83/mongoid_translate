# encoding: utf-8
module Translation
  class Foo
    include Mongoid::Document
    include Mongoid::Translation
    include Mongoid::Translation::Slug
  end
end
