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

  describe Mongoid::Translation::Slug do
    before do
      model_with_translation.save
    end

    describe 'validation' do
      it 'should be valid' do
        model_with_translation.should be_valid
      end

      it 'should not be valid if this slug already exist' do
        model = Foo.new
        model.main_language = :fr
        model.translations.build(title: 'En français', slug: 'en-francais')
        model.should_not be_valid
        model.errors.messages.keys.should include :translations
      end

      it 'should not be valid if this slug already exist' do
        model = Foo.new
        model.main_language = :fr
        model.translations.build(title: 'En français', slug: 'en-francais')
        model.translations.build(title: 'En japonais', slug: '日本語で', language: :ja)
        model.should_not be_valid
        model.errors.messages.keys.should include :translations
      end
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
        foo.save
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
