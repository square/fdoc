require 'yaml'

# Services represent a group of Fdoc API endpoints in a directory
class Fdoc::Service
  attr_reader :service_dir

  def initialize(service_dir)
    @service_dir = service_dir
    @schema = if service_path = Dir["#{service_dir}/*.fdoc.service"].first
      YAML.load_file(service_path)
    else
      {}
    end
  end

  DefaultService = self.new(Fdoc::DEFAULT_SERVICE_PATH)

  # Returns an Endpoint described by (verb, path)
  # In scaffold_mode, it will return an EndpointScaffold an of existing file
  #   or create an empty EndpointScaffold
  def open(verb, path, scaffold_mode = Fdoc.scaffold_mode?)
    endpoint_path = path_for(verb, path)

    if scaffold_mode
      Fdoc::EndpointScaffold.new(endpoint_path, self)
    else
      Fdoc::Endpoint.new(endpoint_path, self)
    end
  end

  def endpoint_paths
    Dir["#{service_dir}/**/*.fdoc"]
  end

  def endpoints
    endpoint_paths.map do |path|
      Fdoc::Endpoint.new(path, self)
    end
  end

  def path_for(verb, path)
    flat_path   = File.join(@service_dir, "#{path}-#{verb.upcase}.fdoc")
    nested_path = File.join(@service_dir, "#{path}/#{verb.upcase}.fdoc")

    if File.exist?(flat_path)
      flat_path
    elsif File.exist?(nested_path)
      nested_path
    else # neither exists, default to flat_path
      flat_path
    end
  end

  def name
    @schema['name']
  end

  def base_path
    @schema['basePath']
  end

  def description
    @schema['description']
  end
end