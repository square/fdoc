# EndpointScaffolds aggregate input to guess at the structure of an API
# endpoint. The #consume_* methods can modify the structure of the
# in-memory endpoint, to save the results to the file system, call #persist!
class Fdoc::EndpointScaffold < Fdoc::Endpoint
  def initialize(endpoint_path, service=Fdoc::Service.default_service)
    if File.exist?(endpoint_path)
      super
    else
      @endpoint_path = endpoint_path
      @schema = {
        "description" => "???",
        "responseCodes" => []
      }
      @service = service
    end
  end

  def persist!
    dirname = File.dirname(@endpoint_path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    File.open(@endpoint_path, "w") do |file|
      YAML.dump(@schema, file)
    end
  end

  def consume_request(params, successful = true)
    scaffold_schema(request_parameters, stringify_keys(params), {
      :root_object => true
    })
  end

  def consume_response(params, status_code, successful=true)
    if successful
      scaffold_schema(response_parameters, stringify_keys(params), {
        :root_object => true
      })
    end

    response_code = response_codes.find do
      |rc| rc["status"] == status_code && rc["successful"] == successful
    end

    if !response_code
      response_codes << {
        "status" => status_code,
        "successful" => successful,
        "description" => "???"
      }
    end
  end

  protected

  def scaffold_schema(schema, params, options = {:root_object => false})
    unless options[:root_object]
      schema["description"] ||= "???"
      schema["required"] = "???" unless schema.has_key?("required")
    end

    if params.kind_of? Hash
      scaffold_hash(schema, params, options)
    elsif params.kind_of? Array
      scaffold_array(schema, params, options)
    else
      scaffold_atom(schema, params, options)
    end
  end

  def scaffold_hash(schema, params, options = {})
    schema["type"] ||= "object" unless options[:root_object]
    schema["properties"] ||= {}

    params.each do |key, value|
      unless schema[key]
        schema["properties"][key] ||= {}
        sub_options = options.merge(:root_object => false)
        scaffold_schema(schema["properties"][key], value, sub_options)
      end
    end
  end

  def scaffold_array(schema, params, options = {})
    schema["type"] ||= "array"
    schema["items"] ||= {}
    params.each do |arr_value|
      sub_options = options.merge(:root_object => false)
      scaffold_schema(schema["items"], arr_value, options.merge(sub_options))
    end
  end

  def scaffold_atom(schema, params, options = {})
    value = params
    schema["type"] ||= guess_type(params)
    if format = guess_format(params)
      schema["format"] ||= format
    end
    schema["example"] ||= value
  end

  def guess_type(value)
    in_type = value.class.to_s
    type_map = {
      "Fixnum" => "integer",
      "Float" => "number",
      "Hash" => "object",
      "Time" => "string",
      "TrueClass" => "boolean",
      "FalseClass" => "boolean",
      "NilClass" => "null"
    }
    type_map[in_type] || in_type.downcase
  end

  def guess_format(value)
    if value.kind_of? Time
      "date-time"
    elsif value.kind_of? String
      if value.start_with? "http://"
        "uri"
      elsif value.match(/\#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?\b/)
        "color"
      else
        begin
          "date-time" if Time.iso8601(value)
        rescue
          nil
        end
      end
    end
  end
end
