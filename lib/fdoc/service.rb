require 'yaml'

# Services represent a group of Fdoc API endpoints in a directory
class Fdoc::Service
  attr_reader :service_dir
  attr_accessor :meta_service

  def self.default_service
    new(Fdoc.service_path)
  end

  def initialize(service_dir, scaffold_mode = Fdoc.scaffold_mode?)
    @service_dir = File.expand_path(service_dir)
    service_path = Dir["#{@service_dir}/*.fdoc.service"].first
    @schema = if service_path
      YAML.load_file(service_path)
    elsif scaffold_mode
      schema = {
        'name'        => '???',
        'basePath'    => '???',
        'description' => '???'
      }

      Dir.mkdir(service_dir) unless Dir.exist?(service_dir)
      service_path = "#{service_dir}/???.fdoc.service"
      File.open(service_path, "w") { |file| YAML.dump(schema, file) }

      schema
    else
      {}
    end
  end

  def self.verify!(verb, path, request_params, response_params, path_params,
                   response_status, successful)
    service = Fdoc::Service.new(Fdoc.service_path)
    endpoint = service.open(verb, path)
    endpoint.consume_path(path_params, successful)
    endpoint.consume_request(request_params, successful)
    endpoint.consume_response(response_params, response_status, successful)
    endpoint.persist! if endpoint.respond_to?(:persist!)
  end

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
    flat_path   = File.join(@service_dir, "#{path}-#{verb.to_s.upcase}.fdoc")
    nested_path = File.join(@service_dir, "#{path}/#{verb.to_s.upcase}.fdoc")

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
    base_path = @schema['basePath']
    if base_path && !base_path.end_with?('/')
      base_path + '/'
    else
      base_path
    end
  end

  def description
    @schema['description']
  end

  def discussion
    @schema['discussion']
  end
end
