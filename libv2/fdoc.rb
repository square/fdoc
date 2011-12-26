lib_dir = File.expand_path(File.dirname(__FILE__) + "/fdoc")
$:.unshift(lib_dir)

module Fdoc
  def self.load(path = "docs/fdoc")
    @resources = {}
    Dir.foreach(path) do |file|
      next unless file.end_with? ".fdoc"
      resource = Resource.build_from_file(File.join(path, "/#{file}"))
      @resources[resource.controller] = resource
    end
  end
  
  def self.clear
    @resources = {}
  end
  
  def self.schema
    YAML.load_file("../fdoc-schema.yaml")
  end
  
  def self.resource_for(controller_name)
    resource = @resources[controller_name]
    unless resource.nil? or resource.scaffold?
      resource
    else
      nil
    end
  end
  
  def self.scaffold_for(controller_name)
    resource = @resources[controller_name]
    if resource
      if not resource.scaffold?
        raise ResourceAlreadyExistsError, "Resource for #{controller_name} already exists, can't scaffold"
      else
        resource
      end
    end
    
    camel_case_resource = controller_name.split(':').last.match(/(.*)(?:Controller?)/)[1]
    snake_case_resource = camel_case_resource.gsub(/^([A-Z])/) { |m| m.downcase}.gsub(/([A-Z])/) {|m| "_#{m.downcase}" }

    @resources[controller_name] = Resource.new ({
      "controller" => controller_name,
      "resourceName" => snake_case_resource,
      "description" => "???",
      "scaffold" => true
    })
  end
  
  def self.compile_index(fdoc_directory, base_path, options = {})
    # creates an HTML index page that links to pages for fdocs in a given folder
    # uses an ERB template, outputs a string
  end
  
  def self.compile(fdoc_path, base_path, options = {})
    # creates an HTML page for an individual fdoc file
    # uses an ERB template, outputs a string
  end
  
  class Error < StandardError; end
  
  class ResourceAlreadyExistsError < Error; end
  class ActionAlreadyExistsError < Error; end
  
  class DocumentationError < Error; end
  class UndocumentedResponseCode < Error; end
end

require 'resource'
require 'action'
