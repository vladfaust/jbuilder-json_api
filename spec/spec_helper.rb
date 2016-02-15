$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jbuilder/json_api'
require 'factory_girl'
require './spec/support/dummies'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    # Force FactoryGirl sequences to be fully reset before each test run to simplify ID testing
    # since we are not using a database or real fixtures. Inside of each test case, IDs will
    # increment per type starting at 1.
    FactoryGirl.reload
    load 'factory.rb'
  end
end
