# encoding: utf-8
require "spec_helper"

describe Mongoid::Translate do
  let(:french_translation_hash) { {:title => "En français",
                                   :content => "C'est du français",
                                   :language => :fr} }
  let(:french_translation) {Translation::Foo.new(french_translation_hash)}
  let(:namespace_french_translation) {Bar::Translation::PlopNew.new(french_translation_hash)}
  let(:japanese_translation) {Translation::Foo.new(:title => "日本語で",
                                                     :content => "確かに日本語なんです",
                                                     :language => :ja)}
  let(:namespace_japanese_translation) {Bar::Translation::PlopNew.new(:title => "日本語で",
                                                     :content => "確かに日本語なんです",
                                                     :language => :ja)}
  let(:model_with_translation) do
    model = Foo.new
    model.main_language = :fr
    model.translations << french_translation
    model.translations << japanese_translation
    model
  end

  let(:namespace_model_with_translation) do
    model = Bar::PlopNew.new
    model.main_language = :fr
    model.translations << french_translation
    model.translations << japanese_translation
    model
  end

  context 'when models are namespaced' do

    it 'should have a translation' do
      namespace_model_with_translation.translations.first.title.should eq('En français')
    end

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

  context 'easy access' do
    it 'should access japanese translation' do
      model_with_translation.ja.should eq japanese_translation
    end

    it 'should acces french translation' do
      model_with_translation.fr.should eq french_translation
    end

    it 'should delegate to method missing' do
      lambda {
        model_with_translation.de.should eq french_translation
      }.should raise_error
    end
  end
end
