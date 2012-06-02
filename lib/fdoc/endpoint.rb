require 'yaml'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
class Fdoc::Endpoint
  attr_reader :service
  attr_reader :endpoint_path

  def initialize(endpoint_path, service=Fdoc::Service::DefaultService)
    @endpoint_path = endpoint_path
    @schema = YAML.load_file(@endpoint_path)
    @service = service
  end

  def consume_request(params, successful=true)
    if successful
      parameters_schema = set_additional_properties_false_on(request_parameters.dup)
      JSON::Validator.validate!(parameters_schema, stringify_keys(params))
    end
  end

  def consume_response(params, status_code, successful=true)
    response_code = response_codes.find do |rc|
      rc["status"] == status_code && rc["successful"] == successful
    end

    if !response_code 
      raise Fdoc::UndocumentedResponseCode,
        "Undocumented response: #{status_code}, successful: #{successful.to_s}"
    elsif successful
      response_schema = set_additional_properties_false_on(response_parameters.dup)
      JSON::Validator.validate!(response_schema, stringify_keys(params),
        :validate_schema => false)
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
      if value["type"] == "object"
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

  def stringify_keys(value)
    return value unless value.is_a?(Hash)
    result = {}

    value.each do |k, v|
      result[k.to_s] = stringify_keys(v)
    end

    result
  end
end
