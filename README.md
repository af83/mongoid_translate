# Mongoid Translate

## Usage:

see specs in spec/libs/mongoid/translate

Exemple :

    class Article
      include Mongoid::Document

      # add Translate module
      include Mongoid::Translate

      # declare fields to be translate
      translate :title, :content

    end

Create a Namespace model. You can add callbacks validation and so on.

    class Translation::Article
      include Mongoid::Document

      # add Translation module
      include Mongoid::Translation
    end

That'all folks.

Display translation :

    article = Article.first
    # return title according to I18n.locale, or main_translation.
    article.title

    # return list of existing translation for this resource
    article.languages

    # return main_translation
    article.main_translation


Persist translation. It's just an embeds_many relation.

    article = Article.new
    article.translations << Translation::Article.new(:title => 'My title',
                                                     :language => :en)
