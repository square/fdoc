require 'yaml'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
class Fdoc::Endpoint
  attr_reader :service
  attr_reader :endpoint_path

  def initialize(endpoint_path, service=Fdoc::Service.default_service)
    @endpoint_path = endpoint_path
    @schema = IncludeBuilder.new(@endpoint_path).schema
    @service = service
  end

  class IncludeBuilder

    attr_reader :schema

    def initialize(path)
      @path = path

      contents = File.read(@path)

      i, includes = 0, {}
      contents = contents.gsub(/\{([^\}]*)\}/) do
        i += 1
        includes[i.to_s] = IncludeBuilder.new("#{FDOC_DIRECTORY}#{$1}").schema
        "include_#{i}"
      end

      @schema = YAML.load(contents)
      replace_includes(@schema, includes)
    end

    def replace_includes(schema, replacements)
      schema.each do |k, v|
        if v.is_a?(String) && v.match(/include_(\d+)/)
          schema[k] = replacements[$1]
        end

        if v.is_a?(Hash)
          replace_includes(v, replacements)
        end
      end
    end

  end

  def consume_request(params, successful=true)
    if successful
      schema = set_additional_properties_false_on(request_parameters.dup)
      JSON::Validator.validate!(schema, stringify_keys(params))
    end
  end

  def consume_response(params, status_code, successful=true)
    response_code = response_codes.find do |rc|
      rc["successful"] == successful && (
        rc["status"]      == status_code || # 200
        rc["status"].to_i == status_code    # "200 OK"
      )
    end


    if !response_code
      raise Fdoc::UndocumentedResponseCode,
        'Undocumented response: %s, successful: %s' % [
          status_code, successful
        ]
    elsif successful
      schema = set_additional_properties_false_on(response_parameters.dup)
      JSON::Validator.validate!(schema, stringify_keys(params))
    else
      true
    end
  end

  def verb
    @verb ||= endpoint_path.match(/([A-Z]*)\.fdoc$/)[1]
  end

  def path
    @path ||= endpoint_path.
                gsub(service.service_dir, "").
                match(/\/?(.*)[-\/][A-Z]+\.fdoc/)[1]
  end

  # properties

  def deprecated?
    @schema["deprecated"]
  end

  def description
    @schema["description"]
  end

  def request_parameters
    @schema["requestParameters"] ||= {}
  end

  def response_parameters
    @schema["responseParameters"] ||= {}
  end

  def response_codes
    @schema["responseCodes"] ||= []
  end

  protected

  # default additionalProperties on objects to false
  # create a copy, so we don't mutate the input
  def set_additional_properties_false_on(value)
    if value.kind_of? Hash
      copy = value.dup
      if value["type"] == "object" || value.has_key?("properties")
        copy["additionalProperties"] ||= false
      end
      value.each do |key, hash_val|
        unless key == "additionalProperties"
          copy[key] = set_additional_properties_false_on(hash_val)
        end
      end
      copy
    elsif value.kind_of? Array
      copy = value.map do |arr_val|
        set_additional_properties_false_on(arr_val)
      end
    else
      value
    end
  end

  def stringify_keys(obj)
    case obj
    when Hash
      result = {}
      obj.each do |k, v|
        result[k.to_s] = stringify_keys(v)
      end
      result
    when Array then obj.map { |v| stringify_keys(v) }
    else obj
    end
  end
end
