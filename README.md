# Jbuilder::JsonApi | [![Gem Version](https://badge.fury.io/rb/jbuilder-json_api.svg)](https://badge.fury.io/rb/jbuilder-json_api) ![](http://ruby-gem-downloads-badge.herokuapp.com/jbuilder-json_api?color=brightgreen) [![Build Status](https://travis-ci.org/vladfaust/jbuilder-json_api.svg?branch=master)](https://travis-ci.org/vladfaust/jbuilder-json_api) [![Dependency Status](https://gemnasium.com/vladfaust/jbuilder-json_api.svg)](https://gemnasium.com/vladfaust/jbuilder-json_api)

Adds a `json.api_format!(resources)` method to quickly represent a resource or collection in a valid [JSON API](http://jsonapi.org/) format without any new superclasses or weird setups. Set'n'go! :rocket:

## Motivation

Official JSON API [implementations page](http://jsonapi.org/implementations/#server-libraries-ruby) shows us a variety of different serializers and other heavy-weight stuff. I'm in love with [Jbuilder](https://github.com/rails/jbuilder), as it allows to format json responses with ease. Therefore I wanted to connect Jbuilder and JsonApi.org specs.

I'd like to notice that there already is one gem called [jbuilder-jsonapi](https://github.com/csexton/jbuilder-jsonapi) by [csexton](https://github.com/csexton), but it adds a links helper only. It's not enough for me! :facepunch:

As a result, I've created a **very** lightweight & flexible solution - all you need is Jbuilder and this gem. Then you should delete everything within your `*.json.jbuilder` files and replace it with below recommendations (just one line! :flushed:). After you are free to customize parsed attributes and relationships with three tiny methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jbuilder-json_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jbuilder-json_api

## Usage

Replace any content within any `*.json.jbuilder` file with the code below:
```ruby
# Common example
json.api_format! @resources, @errors, meta, options

# Items example
json.api_format! @items, @errors, nil, access_level: :admin

# A simple items example
json.api_format! @items
```
You can also render formatted JSON straight from controller actions:
```ruby
respond_to do |f|
    f.json { render layout: false, json: JSON.parse(JbuilderTemplate.new(view_context).api_format!(@item).target!) }
    f.html { render nothing: true, status: :bad_request }
end
```
Each resource instance, as well as the included one, will be invoked with `json_api_attrs (options)`, `json_api_relations (options)` & `json_api_meta (options)` methods. These methods **MAY** be implemented within each model. `api_format!` method will try to get an object's permitted attributes (**remember, you are free do define authentication logic yourself!**) and relations and meta information via those three methods.

Here is an example of implementation:
```ruby
# Inside Item model

def json_api_attrs (options = {})
  attrs = []
  attrs += %w(name description price buyoutable item_type category) if %i(user admin).include?options[:access_level]
  attrs += %w(real_price in_stock) if options[:access_level] == :admin
  attrs
end

def json_api_relations (options = {})
  %w(category orders)
end
```
**Note** that the gem will call methods pulled via `json_api_relations and _attrs`. As for the above example, methods like `:name`, `:description`, `:real_price`, `:orders` will be invoked for an Item instance. And yes, relations are fetched properly and recursively if the object responds to `orders`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/vladfaust/jbuilder-json_api](https://github.com/vladfaust/jbuilder-json_api). It would be really good if someone contributes. :smile:

## ToDo

- [ ] Maybe add `Content-Type: application/vnd.api+json`. This spec is ignored right now :smirk:
- [ ] Add links tests and improve them. Links now work only within views (where `@context` is present).
- [ ] Somehow implement `[fields]` parameter

## Versions

#### 0.0.1 -> 1.0.0

**Breaking:**
- [x] Now any value can be forwarded to resources' methods via last `options` argument.
- [x] Added third argument `meta`, which is used to show meta information in the context of request

**Not breaking:**
- [x] Added support for `json_api_meta (options)` method.
- [x] Any internal error is now properly handled.