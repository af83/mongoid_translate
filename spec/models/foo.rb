# encoding: utf-8
class Foo
  include Mongoid::Document
  include Mongoid::Translate
  include Mongoid::Translate::Slug

  translate :title, :content
  slug_field :title
end
