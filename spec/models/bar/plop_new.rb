# encoding: utf-8
module Bar
  class PlopNew
    include Mongoid::Document
    include Mongoid::Translate

    translate :title, :content
  end
end
