# encoding: utf-8
require "spec_helper"

module Bar
  class PlopNew
    include Mongoid::Document
    include Mongoid::Translate

    translate :title, :content
  end
end

module Bar
  module Translation
    class PlopNew
      include Mongoid::Document
      include Mongoid::Translation
    end
  end
end

class Foo
  include Mongoid::Document
  include Mongoid::Translate
  include Mongoid::Translate::Slug

  translate :title, :content
  slug_field :title
end

module Translation
  class Foo
    include Mongoid::Document
    include Mongoid::Translation
    include Mongoid::Translation::Slug
  end
end

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

  describe Mongoid::Translation::Slug do
    before do
      model_with_translation.save
    end

    describe 'slug creation' do
      it 'should have a slug in fr' do
        model_with_translation.translations.first.slug.should_not be_nil
        model_with_translation.translations.first.slug.should eq "en-francais"
      end

      it 'should have a slug in ja' do
        model_with_translation.translations.last.slug.should_not be_nil
        model_with_translation.translations.last.slug.should eq "日本語で"
      end

      it 'should not change slug' do
        model_with_translation.translations.first.title = 'test'
        model_with_translation.save
        model_with_translation.reload.translations.first.title.should eq 'test'
        model_with_translation.translations.first.slug.should eq "en-francais"
      end

      it 'should add a token to a already existing slug' do
        model_with_translation
        foo = Foo.new
        foo.translations.create(french_translation_hash)
        foo.save
        Foo.all.count.should eq 2
        Foo.last.translations.first.slug.should_not eq "en-francais"
        Foo.last.reload.translations.first.slug.should match "en-francais"
      end
    end

    describe 'to_slug' do

      it 'should have a to_slug method in fr' do
        I18n.locale = :fr
        model_with_translation.to_slug.should eq french_translation.slug
      end

      it 'should have a to_slug method in ja' do
        I18n.locale = :ja
        model_with_translation.to_slug.should eq japanese_translation.slug
      end

    end

    describe 'by_slug scope' do
      before do
        model_with_translation
      end

      it 'should responds to by_slug' do
        Foo.respond_to?(:by_slug).should be_true
      end

      it 'should find by with french translation' do
        Foo.by_slug(french_translation.slug).one.should eq model_with_translation
      end

      it 'should find by with japanese translation' do
        Foo.by_slug(japanese_translation.slug).one.should eq model_with_translation
      end

      it 'should return nil with unknow slug' do
        Foo.by_slug('plop').one.should be_nil
      end
    end

  end
end
