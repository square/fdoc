lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  require 'method_checklist'
  require 'resource_checklist'
  
  def self.load(path = 'docs/fdoc')
    @resource_checklists = {}

    Dir.foreach(path) do |file|
      next if file == '.' || file == '..'
      resource_checklist = ResourceChecklist.new(path + "/#{file}")
      @resource_checklists[resource_checklist.controller] = resource_checklist
    end
  end
  
  def self.resource_for(controller)
    @resource_checklists[controller].dup
  end
end