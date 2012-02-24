class Fdoc::ActionPresenter < Fdoc::HTMLPresenter
  def initialize(action, resource_href, base_path, options = {})
    super action, base_path, options
    @resource_href = resource_href.strip
    if @resource_href.end_with? "/"
      @resource_href = @resource_href[0..-2]
    end
  end

  def action
    presented
  end

  def name_as_html
    "<span class=\"verb\">#{action.verb.strip}</span> " +
    "<span class=\"base-path\">#{@resource_href}</span>" +
    "<span class=\"name\">#{action_name}</span>"
  end

  def html_id
    action.name
  end

  def action_name
    action_name = action.name.strip
    unless action_name.start_with? "/"
      action_name = "/" + action_name
    end
    action_name
  end

  def request_parameters
    action.request_parameters
  end

  def required_request_parameters
    (request_parameters["properties"] || {}).select { |key, value| value["required"] }
  end

  def optional_request_parameters
    (request_parameters["properties"] || {}).select { |key, value| not value["required"] }
  end

  def response_parameters
    action.response_parameters["properties"] || {}
  end

  def successful_response_codes
    action.response_codes.select { |value| value["successful"] }
  end

  def failure_response_codes
    action.response_codes.select { |value| not value["successful"] }
  end

  def example_request
    self.class.example_from_schema(action.request_parameters)
  end

  def example_response
    self.class.example_from_schema(action.response_parameters)
  end

  private

  def self.example_from_schema(schema)
    type = schema["type"]
    if type == "string" or type == "integer" or type == "number" or type == "null"
      schema["example"] || schema["default"] || nil
    elsif type == "object" or schema["properties"]
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
