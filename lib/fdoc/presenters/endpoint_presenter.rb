# BasePresenter for an Endpoint
class Fdoc::EndpointPresenter < Fdoc::BasePresenter
  attr_accessor :service_presenter, :endpoint, :endpoint_presenter

  def initialize(endpoint, options = {})
    super(options)
    @endpoint = endpoint
    @endpoint_presenter = self
  end

  def to_html
    render_erb('endpoint.html.erb')
  end

  def to_markdown
    render_erb('endpoint.md.erb')
  end

  def url(extension = ".html")
    '%s%s-%s%s' % [ options[:prefix], endpoint.path, endpoint.verb, extension ]
  end

  def title
    '%s %s - %s' % [ endpoint.verb, endpoint.path, endpoint.service.name ]
  end

  def prefix
    endpoint.path.split("/").first
  end

  def zws_ify(str)
    # zero-width-space, makes long lines friendlier for breaking
    str.gsub(/\//, '&#8203;/') if str
  end

  def description
    render_markdown(endpoint.description)
  end

  def show_request?
    !endpoint.request_parameters.empty?
  end

  def show_response?
    !endpoint.response_parameters.empty?
  end

  def request_parameters
    Fdoc::SchemaPresenter.new(endpoint.request_parameters,
      options.merge(:request => true)
    )
  end

  def response_parameters
    Fdoc::SchemaPresenter.new(endpoint.response_parameters, options)
  end

  def response_codes
    @response_codes ||= endpoint.response_codes.map do |response_code|
      Fdoc::ResponseCodePresenter.new(response_code, options)
    end
  end

  def successful_response_codes
    response_codes.select { |response_code| response_code.successful? }
  end

  def failure_response_codes
    response_codes.select { |response_code| !response_code.successful? }
  end

  def example_request
    Fdoc::JsonPresenter.new(example_from_schema(endpoint.request_parameters))
  end

  def example_response
    Fdoc::JsonPresenter.new(example_from_schema(endpoint.response_parameters))
  end

  def deprecated?
    @endpoint.deprecated?
  end

  def base_path
    zws_ify(@endpoint.service.base_path)
  end

  def path
    zws_ify(@endpoint.path)
  end

  ATOMIC_TYPES = %w(string integer number boolean null)

  def example_from_schema(schema)
    if schema.nil?
      return nil
    end

    type = Array(schema["type"])

    if type.any? { |t| ATOMIC_TYPES.include?(t) }
      schema["example"] || schema["default"] || example_from_atom(schema)
    elsif type.include?("object") || schema["properties"]
      example_from_object(schema)
    elsif type.include?("array") || schema["items"]
      example_from_array(schema)
    else
      {}
    end
  end

  def example_from_atom(schema)
    type = Array(schema["type"])
    hash = schema.hash

    if type.include?("boolean")
      [true, false][hash % 2]
    elsif type.include?("integer")
      hash % 1000
    elsif type.include?("number")
      Math.sqrt(hash % 1000).round 2
    elsif type.include?("string")
      ""
    else
      nil
    end
  end

  def example_from_object(object)
    example = {}
    if object["properties"]
      object["properties"].each do |key, value|
        example[key] = example_from_schema(value)
      end
    end
    example
  end

  def example_from_array(array)
    if array["items"].kind_of? Array
      example = []
      array["items"].each do |item|
        example << example_from_schema(item)
      end
      example
    elsif (array["items"] || {})["type"].kind_of? Array
      example = []
      array["items"]["type"].each do |item|
        example << example_from_schema(item)
      end
      example
    else
      [ example_from_schema(array["items"]) ]
    end
  end
end
