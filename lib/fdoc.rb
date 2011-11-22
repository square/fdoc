lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  def self.load(path = 'docs/fdoc')
    @resources = {}

    Dir.foreach(path) do |file|
      next unless file.end_with? ".fdoc"
      resource = Resource.build_from_file(path + "/#{file}")
      @resources[resource.controller] = resource
    end
  end

  def self.checklist_for(controller, methodname)
    return nil unless resource = @resources[controller]
    method = resource.action_named(methodname.to_s)
    raise UndocumentedMethodError, "Undocumented method named #{methodname}" unless method
    MethodChecklist.new(method)
  end

  def self.scaffold_for(controller, methodname)
    unless resource = @resources[controller]
      resource = ResourceScaffold.scaffold_resource(controller)
      @resources[controller] = resource
    end

    if method = resource.action_named(methodname)
      scaffold = MethodScaffold.new(method)
    else
      scaffold = MethodScaffold.new(methodname)
      resource.actions << scaffold.scaffolded_method
    end

    scaffold
  end

  def self.resource_for(controller)
    @resources[controller]
  end

  def self.template_path(template, file_type = "erb")
    File.expand_path(File.dirname(__FILE__) + "/templates/#{template}.#{file_type}")
  end

  def self.compile_index(fdoc_directory, base_path, options = {})
    resources = []

    Dir.foreach(fdoc_directory) do |file|
      next unless file.end_with? ".fdoc"
      resource = Fdoc::Resource.build_from_file(fdoc_directory + "/#{file}")
      resources << resource
    end

    directory_template = ERB.new(File.read(template_path(:directory)))
    d = Fdoc::DirectoryPage.new(resources, base_path, options)
    directory_template.result(d.get_binding)
  end

  def self.compile(fdoc_path, base_path, options = {})
    resource_template = ERB.new(File.read(template_path(:resource)))
    resource = Fdoc::Resource.build_from_file(fdoc_path)
    p = Fdoc::ResourcePage.new(resource, base_path, options)

    resource_template.result(p.get_binding)
  end

  def self.css
    File.read(template_path(:main, :css))
  end

  class Error < StandardError; end
  class MissingAttributeError < Error; end

  class DocumentationError < Error; end
  class UndocumentedParameterError < DocumentationError; end
  class MissingRequiredParameterError < DocumentationError; end
  class UndocumentedResponseCodeError < DocumentationError; end
  class UndocumentedMethodError < DocumentationError; end
end

require 'node'
require 'doc_node'
require 'parameter'
require 'request_parameter'
require 'response_parameter'
require 'page'
require 'response_code'
require 'method'
require 'resource'
require 'method_checklist'
require 'resource_scaffold'
require 'method_scaffold'
require 'presenter'
require 'parameter_presenter'
