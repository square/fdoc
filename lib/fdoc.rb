lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  class Page
    def initialize(resource)
      @resource = resource
    end

    def get_binding
      binding
    end
  end

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

  def self.compile(fdoc_path)
    template_path = File.expand_path(File.dirname(__FILE__) + "/templates/resource.erb")

    resource = Fdoc::Resource.build_from_file(template_path)
    p = Fdoc::Page.new(resource)

    template.result(p.get_binding)
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
