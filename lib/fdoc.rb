lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  class Page
    def get_binding
      binding
    end

    def index_path
      path = @base_path
      path = "/" + path unless @options[:html]
      path
    end

    def css_path
      path = "#{@base_path}/main.css"
      path = "/" + path unless @options[:html]
      path
    end
  end
  
  class DirectoryPage < Page
    def initialize(resources, base_path, options = {})
      @resources = resources
      @base_path = base_path
      @options = options
    end
    
    def resource_path(resource)
      path = "#{@base_path}/#{resource.name}"
      if @options[:html]
        path += ".html"
      else
        path = "/" + path
      end
      path
    end    
  end  

  class ResourcePage < Page
    def initialize(resource, base_path, options = {})
      @resource = resource
      @base_path = base_path
      @options = options
    end
  end

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
    if resource = @resources[controller]
      scaffold = MethodScaffold.new(resource.action_named(methodname))
    else
      resource = ResourceScaffold.scaffold_resource(controller)
      scaffold = MethodScaffold.new(methodname)
      resource.actions << scaffold.scaffolded_method
      @resources[controller] = resource 
    end
    scaffold
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
require 'parameter'
require 'request_parameter'
require 'response_parameter'
require 'response_code'
require 'method'
require 'resource'
require 'method_checklist'
require 'resource_scaffold'
require 'method_scaffold'
