spec_dir = File.expand_path(File.dirname(__FILE__))
$:.unshift("#{spec_dir}/../lib/models")
$:.unshift("#{spec_dir}/../lib/presenters")
$:.unshift("#{spec_dir}/fixtures")

require 'rspec'
require 'fdoc'
require 'yaml'
require 'json'
require 'json-schema'
require 'libxml'
require 'erb'

FIXTURES_PATH = "#{spec_dir}/fixtures"
