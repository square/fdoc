class Fdoc::EndpointPresenter < Fdoc::HtmlPresenter
  def initialize(endpoint, options = {})
    super(options)
    @endpoint = endpoint
  end

  def to_html
    render_erb('endpoint.html.erb')
  end

  def name
    <<-EOS
    <span class="endpoint-name">
      <span class="verb">#{@endpoint.verb}</span>
      <span class="root">#{@endpoint.service.base_path}</span><span
       class="path">#{@endpoint.path}</span>
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

  def example_from_schema(schema)
    return unless schema
    type = schema["type"]
    if type == "string" || type == "integer" || type == "number" ||
       type == "null" || type == "boolean"
      schema["example"] || schema["default"] || nil
    elsif schema["properties"]
      example = {}
      schema["properties"].each do |key, value|
        example[key] = example_from_schema(value)
      end
      example
    elsif type == "array" or schema["items"]
      if schema["items"].kind_of? Array
        example = []
        schema["items"].each do |item|
          example << example_from_schema(item)
        end
        example
      else
        [example_from_schema(schema["items"])]
      end
    else
      {}
    end
  end
end