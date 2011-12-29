require 'json-schema'

module Fdoc
  class << self
    def load(path = "docs/fdoc")
      @resources = {}
      Dir.foreach(path) do |file|
        next unless file.end_with? ".fdoc"
        resource = Resource.build_from_file(File.join(path, file))
        @resources[resource.controller] = resource
      end
    end

    def clear
      @resources = {}
    end

    def schema
      @schema ||= YAML.load_file(File.join(File.dirname(__FILE__), "../fdoc-schema.yaml"))
    end

    def resources
      @resources.values
    end

    def resource_for(controller_name)
      resource = @resources[controller_name]
      unless resource.nil? or resource.scaffold?
        resource
      else
        nil
      end
    end

    def scaffold_for(controller_name)
      if resource = @resources[controller_name]
        if not resource.scaffold?
          raise ResourceAlreadyExistsError,
            "Resource for #{controller_name} already exists, can't scaffold"
        else
          return resource
        end
      end

      camel_case_resource = controller_name.split(':').last.match(/(.*)(?:Controller?)/)[1]
      snake_case_resource = camel_case_resource.gsub(/^([A-Z])/) { |m| m.downcase}.gsub(/([A-Z])/) {|m| "_#{m.downcase}" }

      @resources[controller_name] = Resource.new({
        "controller" => controller_name,
        "resourceName" => snake_case_resource,
        "description" => "???",
        "basePath" => "https://???/#{snake_case_resource}",
        "scaffold" => true
      })
    end

    def template_path(template, file_type = "erb")
      File.expand_path(File.dirname(__FILE__) + "/templates/#{template}.#{file_type}")
    end

    def compile_index(base_path, options = {})
      directory_template = ERB.new(File.read(template_path(:directory)))
      d = HTMLPresenter.new(self, base_path, options)
      directory_template.result(d.get_binding)
    end

    def compile(resource_name, base_path, options = {})
      resource = resources.find { |r| r.name == resource_name }

      resource_template = ERB.new(File.read(template_path(:resource)))
      r = ResourcePresenter.new(resource, base_path, options)
      resource_template.result(r.get_binding)
    end

    def css
      File.read(template_path(:main, :css))
    end
  end

  class Error < StandardError; end

  class ResourceAlreadyExistsError < Error; end
  class ActionAlreadyExistsError < Error; end

  class DocumentationError < Error; end
  class UndocumentedResponseCode < Error; end
end

require 'fdoc'
require 'fdoc/models/resource'
require 'fdoc/models/action'
require 'fdoc/presenters/html_presenter'
require 'fdoc/presenters/resource_presenter'
require 'fdoc/presenters/action_presenter'
require 'fdoc/presenters/parameter_presenter'
require 'fdoc/presenters/response_code_presenter'
