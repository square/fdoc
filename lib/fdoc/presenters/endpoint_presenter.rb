# HtmlPresenter for an Endpoint
class Fdoc::EndpointPresenter < Fdoc::HtmlPresenter
  attr_accessor :service_presenter

  def initialize(endpoint, options = {})
    super(options)
    @endpoint = endpoint
  end

  def to_html
    render_erb('endpoint.html.erb')
  end

  def name
    <<-EOS
    <span class="endpoint-name #{@endpoint.deprecated? ? 'deprecated' : nil}">
      <span class="verb">#{@endpoint.verb}</span>
      <span class="root">#{zws_ify(@endpoint.service.base_path)}</span><span
       class="path">#{zws_ify(@endpoint.path)}</span>
      #{@endpoint.deprecated? ? '(deprecated)' : nil}
    </span>
    EOS
  end

  def name_as_link
    <<-EOS
    <a href="#{url}">
      #{name}
    </a>
    EOS
  end

  def url(extension = ".html")
    '%s-%s%s' % [ @endpoint.path, @endpoint.verb, extension ]
  end

  def title
    '%s %s - %s' % [ @endpoint.verb, @endpoint.path, @endpoint.service.name ]
  end

  def prefix
    @endpoint.path.split("/").first
  end

  def zws_ify(str)
    # zero-width-space, makes long lines friendlier for breaking
    str.gsub(/\//, '&#8203;/') if str
  end

  def description
    render_markdown(@endpoint.description)
  end

  def show_request?
    !@endpoint.request_parameters.empty?
  end

  def show_response?
    !@endpoint.response_parameters.empty?
  end

  def request_parameters
    Fdoc::SchemaPresenter.new(@endpoint.request_parameters,
      options.merge(:request => true)
    ).to_html
  end

  def response_parameters
    Fdoc::SchemaPresenter.new(@endpoint.response_parameters, options).to_html
  end

  def response_codes
    @response_codes ||= @endpoint.response_codes.map do |response_code|
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
    render_json(example_from_schema(@endpoint.request_parameters))
  end

  def example_response
    render_json(example_from_schema(@endpoint.response_parameters))
  end

  ATOMIC_TYPES = %w(string integer number boolean null)

  def example_from_schema(schema)
    if schema.nil?
      return nil
    end

    type = Array(schema["type"])

    if type.any? { |t| ATOMIC_TYPES.include?(t) }
      schema["example"] || schema["default"] || nil
    elsif type.include?("object") || schema["properties"]
      example_from_object(schema)
    elsif type.include?("array") || schema["items"]
      example_from_array(schema)
    else
      {}
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
    else
      [ example_from_schema(array["items"]) ]
    end
  end
end
