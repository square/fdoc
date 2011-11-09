lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  def self.load(path = 'docs/fdoc')
    @resource_checklists = {}

    Dir.foreach(path) do |file|
      next if file == '.' || file == '..'
      resource_checklist = ResourceChecklist.build_from_file(path + "/#{file}")
      @resource_checklists[resource_checklist.controller] = resource_checklist
    end
  end
  
  def self.resource_for(controller)
    @resource_checklists[controller].dup
  end
  
  class Error < StandardError; end
  class MissingAttributeError < Error; end
end

require 'method_checklist'
require 'resource_checklist'
require 'node'
require 'resource'
require 'action'
require 'parameter'
require 'response'
