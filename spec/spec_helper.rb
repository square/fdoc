require 'fdoc'
require 'fdoc/cli'
require 'rspec'
require 'tmpdir'
require 'rspec/its'
require 'rspec/collection_matchers'

Dir.glob(File.expand_path("../support/*.rb", __FILE__)).each { |f| require f }

RSpec.configure do |config|
  config.include CaptureHelper
end
