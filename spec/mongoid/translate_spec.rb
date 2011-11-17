# encoding: utf-8
require "spec_helper"

class Foo
  include Mongoid::Document
  include Mongoid::Translation

  field :title,     String
  field :content,   String

  translate :title, :content
end

class Translation::Foo
  include Mongoid::Document
  include Mongoid::Translation
end

describe Mongoid::Translate do
  let(:french_translation_hash) { {:title => "En français",
                                   :content => "C'est du français",
                                   :language => :fr} }
  let(:french_translation) {Translation::Foo.new(french_translation_hash)}
  let(:japanese_translation) {Translation::Foo.new(:title => "日本語で",
                                                     :content => "確かに日本語なんです",
                                                     :language => :ja)}
  let(:classified_with_translation) do
    classified = Foo.new
    classified.main_language = :fr
    classified.translations.first.update_attributes(french_translation_hash)
    classified.translations << japanese_translation
    classified
  end

  it 'should have a translation' do
    classified_with_translation.translations.first.title.should eq('En français')
  end

  it 'should return main language' do
    classified_with_translation.main_translation.title.should eq french_translation.title
  end

  it 'should return a list of translation' do
    classified_with_translation.languages.should eq([:fr, :ja])
  end

  it 'should respond_to title' do
    classified_with_translation.respond_to?(:title).should be_true
  end

  it 'should not mess with method missing' do
    expect {
      classified_with_translation.no_method
    }.to raise_error(NoMethodError)
  end

  context 'I18n == :fr' do
    before do
      I18n.locale = :fr
    end

    it 'should return a title from translation' do
      classified_with_translation.title.should eq('En français')
    end

  end

  context 'I18n == :ja' do
    before do
      I18n.locale = :ja
    end

    it 'should return a title from translation' do
      classified_with_translation.title.should eq('日本語で')
    end

  end

  context 'I18n == :en' do
    before do
      I18n.locale = :en
    end

    it 'should return main_language' do
      classified_with_translation.title.should eq('En français')
    end
  end
end
