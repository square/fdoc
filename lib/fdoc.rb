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

  def self.template_path(template, file_type = "erb")
    File.expand_path(File.dirname(__FILE__) + "/templates/#{template}.#{file_type}")
  end

  def self.compile_index(fdoc_directory, base_path, options = {})
    directory_template = ERB.new(File.read(template_path(:directory)))

    resources = []

    Dir.foreach(fdoc_directory) do |file|
      next unless file.end_with? ".fdoc"
      resource = Fdoc::Resource.build_from_file(fdoc_directory + "/#{file}")
      resources << resource
    end

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
require 'resource_checklist'
