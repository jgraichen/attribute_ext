
require File.dirname(__FILE__) + '/support/fake_environment'
require File.dirname(__FILE__) + '/../init'
require File.dirname(__FILE__) + '/support/stub'

RSpec.configure do |config|
  config.mock_with :rspec
end