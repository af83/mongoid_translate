# Mongoid Translate

## Installation

Ruby 1.9.2 is required.

Install it with rubygems:

    gem install mongoid_translate

With bundler, add it to your `Gemfile`:

``` ruby
gem "mongoid_translate", "~>1.0.0"
```

## Usage

### Exemple :

``` ruby
class Article
  include Mongoid::Document

  # add Translate module
  include Mongoid::Translate

  # declare fields to be translate
  translate :title, :content

end
```

Create a Namespace model. You can add callbacks validation and so on.

``` ruby
class Translation::Article
  include Mongoid::Document

  # add Translation module
  include Mongoid::Translation
end
```

That'all folks.

Display translation :

``` ruby
article = Article.first
# return title according to I18n.locale, or main_translation.
article.title

# return list of existing translation for this resource
article.languages

# return main_translation
article.main_translation

# return english translation
article.en
```

Persist translation. It's just an embeds_many relation.

``` ruby
article = Article.new
article.translations << Translation::Article.new(:title => 'My title',
                                                 :language => :en)
```

Slug
----

Slug are generated on translation creation. No change are made after.

Slug feature can be added to translated model:

``` ruby
class Article
  include Mongoid::Document

  # add Translate module
  include Mongoid::Translate

  # add Slug module
  include Mongoid::Translate::Slug

  # declare fields to be translate
  translate :title, :content

  # Define field on which slug will be build.
  slug_field :title

end

class Translation::Article
  include Mongoid::Document

  # add Translation module
  include Mongoid::Translation

  # add Slug module
  include Mongoid::Translation::Slug

end
```

# Examples

Controller with InheritedResources
----------------------------------

``` ruby
before_filter :build_translations, only: :edit
before_filter :build_translations_for_new, only: :new

def build_translations
  (I18n.available_locales - resource.languages).each do |language|
    resource.translations.build(language: language)
  end
end

def build_translations_for_new
  (I18n.available_locales - build_resource.languages).each do |language|
    build_resource.translations.build(language: language)
  end
end
```

Use slug on views with to_slug
------------------------------

``` ruby
= link_to e.title, event_path(e.to_slug)
```

Use by_slug in controller with InheritedResources
-------------------------------------------------

``` ruby
def resource
  @event ||= Event.by_slug(params[:id]).one || Event.find(params[:id])
end
```

## Copyright

Copyright (c) 2011-2013 af83

Released under the MIT license
