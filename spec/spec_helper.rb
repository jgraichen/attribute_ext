
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false

  initialize_in_memory_database if in_memory_database?
end