# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jbuilder/json_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'jbuilder-json_api'
  spec.version       = JsonAPI::VERSION
  spec.authors       = ['Vlad Faust']
  spec.email         = ['vladislav.faust@gmail.com']

  spec.summary       = %q{Easily follow jsonapi.org specifications with Jbuilder}
  spec.description   = %q{Adds a method to build a valid JSON API (jsonapi.org) response without any new superclasses or weird setups. Set'n'go!}
  spec.homepage      = %q{https://github.com/vladfaust/jbuilder-json_api}
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*', 'Rakefile', 'README.md']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_dependency 'jbuilder', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'factory_girl', '~> 4.5'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
