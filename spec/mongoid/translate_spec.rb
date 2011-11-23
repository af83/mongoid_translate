# encoding: utf-8
require "spec_helper"

class Foo
  include Mongoid::Document
  include Mongoid::Translate

  translate :title, :content
end

module Translation
  class Foo
    include Mongoid::Document
    include Mongoid::Translation
  end
end

describe Mongoid::Translate do
  let(:french_translation_hash) { {:title => "En français",
                                   :content => "C'est du français",
                                   :language => :fr} }
  let(:french_translation) {Translation::Foo.new(french_translation_hash)}
  let(:japanese_translation) {Translation::Foo.new(:title => "日本語で",
                                                     :content => "確かに日本語なんです",
                                                     :language => :ja)}
  let(:model_with_translation) do
    model = Foo.new
    model.main_language = :fr
    model.translations << french_translation
    model.translations << japanese_translation
    model
  end

  it 'should have a translation' do
    model_with_translation.translations.first.title.should eq('En français')
  end

  it 'should return main language' do
    model_with_translation.main_translation.title.should eq french_translation.title
  end

  it 'should return a list of translation' do
    model_with_translation.languages.should eq([:fr, :ja])
  end

  it 'should respond_to title' do
    model_with_translation.respond_to?(:title).should be_true
  end

  it 'should responds to main_translation?' do
    model_with_translation.translations.first.main_translation?.should be_true
    model_with_translation.translations.last.main_translation?.should be_false
  end

  context 'I18n == :fr' do
    before do
      I18n.locale = :fr
    end

    it 'should return a title from translation' do
      model_with_translation.title.should eq('En français')
    end

  end

  context 'I18n == :ja' do
    before do
      I18n.locale = :ja
    end

    it 'should return a title from translation' do
      model_with_translation.title.should eq('日本語で')
    end

  end

  context 'I18n == :en' do
    before do
      I18n.locale = :en
    end

    it 'should return main_language' do
      model_with_translation.title.should eq('En français')
    end
  end
end
