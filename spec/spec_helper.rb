spec_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift("#{spec_dir}/../lib/")
$:.unshift("#{spec_dir}/fixtures")

require 'rspec'
require 'fdoc'
require 'yaml'

FIXTURE_PATH = "#{spec_dir}/fixtures"