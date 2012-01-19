# encoding: utf-8
module Bar
  module Translation
    class PlopNew
      include Mongoid::Document
      include Mongoid::Translation
    end
  end
end
