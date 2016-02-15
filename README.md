# Jbuilder::JsonApi | [![Build Status](https://travis-ci.org/vladfaust/jbuilder-json_api.svg?branch=master)](https://travis-ci.org/vladfaust/jbuilder-json_api) [![Code Climate](https://codeclimate.com/github/vladfaust/jbuilder-json_api/badges/gpa.svg)](https://codeclimate.com/github/vladfaust/jbuilder-json_api) [![Test Coverage](https://codeclimate.com/github/vladfaust/jbuilder-json_api/badges/coverage.svg)](https://codeclimate.com/github/vladfaust/jbuilder-json_api/coverage)

Adds a `json.api_format!(resources)` method to quickly represent a resource or collection in a valid [JSON API](http://jsonapi.org/) format without any new superclasses or weird setups. Set'n'go! :rocket:

## Motivation

Official JSON API [implementations page](http://jsonapi.org/implementations/#server-libraries-ruby) shows us a variety of different serializers and other heavy-weight stuff. I' in love with [Jbuilder](https://github.com/rails/jbuilder), as it allows to format json responses with ease. Therefore I wanted to connect Jbuilder and JsonApi.org specs.

I'd like to notice that there already is one gem called [jbuilder-jsonapi](https://github.com/csexton/jbuilder-jsonapi) by [csexton](https://github.com/csexton), but it adds a links helper only. It's not enough for me! :facepunch:

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
json.api_format! @resources, @errors, meta: @meta, access_level: @user_access_level

# Articles w/o meta or access levels example
json.api_format! @articles, @errors
```
You can also render formatted JSON straight from controller actions:
```ruby
respond_to do |f|
    f.json { render layout: false, json: JSON.parse(JbuilderTemplate.new(view_context).api_format!(@item).target!) }
    f.html { render nothing: true, status: :bad_request }
end
```
Each resource instance, as well as the included one, will be invoked with `json_api_attrs` & `json_api_relations` methods. These methods **MAY** be implemented within each model. `api_format!` method will try to get an object's permitted (**you are free do define authentication logic yourself!**) attributes and relations via those two methods.

Here is an example of implementation:
```ruby
# Item model

def json_api_attrs (access_level = nil)
  attrs = []
  attrs += %w(name description price buyoutable item_type category) if %i(user admin).include?access_level
  attrs += %w(real_price in_stock) if access_level == :admin
  attrs
end

def json_api_relations (access_level = nil)
  %w(category orders)
end
```
**Note** that the gem will call methods pulled with `json_api_relations and _attrs`. As for the above example, methods like `:name`, `:description`, `:orders` will be invoked for an Item instance. And yes, relations are fetched properly if an object responds to `orders`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/vladfaust/jbuilder-json_api](https://github.com/vladfaust/jbuilder-json_api). It would be really good if someone contributes. :smile:

## ToDo

- [ ] Maybe add `Content-Type: application/vnd.api+json`. This spec is ignored right now :smirk:
- [ ] Add links tests
- [ ] Somehow implement `[fields]` parameter
