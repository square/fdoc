spec_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift("#{spec_dir}/../libv2/")
$:.unshift("#{spec_dir}/fixtures")

require 'rspec'
require 'fdoc'
require 'yaml'
require 'json'
require 'json-schema'

FIXTURES_PATH = "#{spec_dir}/fixtures"