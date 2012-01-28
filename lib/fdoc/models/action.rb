class Fdoc::Action
  def initialize(action_hash)
    @action = action_hash
  end

  def consume_request(params)
    # may need to dive down and replace $refs with
    # the appropriate types from its resource (parent)
    parameters_schema = set_additional_properties_false_on(request_parameters.dup)
    JSON::Validator.validate!(parameters_schema, stringify_keys(params))
  end

  def consume_response(params, rails_response, successful = true)
    # validates the existence of the HTTP respose/succesful combo
    if not response_codes.find { |rc| rc["status"] == rails_response && rc["successful"] == successful }
      raise Fdoc::UndocumentedResponseCode,
        "Undocumented response: #{rails_response}, successful = #{successful.to_s}"
    elsif successful
      response_schema = set_additional_properties_false_on(response_parameters.dup)
      JSON::Validator.validate!(response_schema, stringify_keys(params), :validate_schema => false)
    else
      true
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

  def scaffold_request(params)
    unless scaffold?
      raise Fdoc::ActionAlreadyExistsError,
        "Action for #{verb} #{name} is not a scaffold, can't scaffold request"
    end

    scaffold_schema(request_parameters, stringify_keys(params), {:root_object => true})
  end

  def scaffold_response(params, rails_response, successful = true)
    unless scaffold?
      raise Fdoc::ActionAlreadyExistsError,
        "Action for #{verb} #{name} is not a scaffold, can't scaffold request"
    end

    if successful
      scaffold_schema(response_parameters, stringify_keys(params), {:root_object => true})
    end

    if not response_codes.find { |rc| rc["status"] == rails_response and rc["successful"] == successful }
      response_codes << {
        "status" => rails_response,
        "successful" => successful,
        "description" => "???"
      }
    end
  end

  # properties. should probably be generated

  def name
    @action["name"]
  end

  def verb
    @action["verb"]
  end

  def scaffold?
    @action["scaffold"]
  end

  def request_parameters
    @action["requestParameters"] ||= {}
  end

  def request_parameters=(params)
    @action["requestParameters"] = params
  end

  def response_parameters
    @action["responseParameters"] ||= {}
  end

  def response_codes
    @action["responseCodes"] ||= []
  end

  private

  def scaffold_schema(schema, params, options = {:root_object => false})
    if params.kind_of? Hash
      schema["type"] ||= "object" unless options[:root_object]
      schema["properties"] ||= {}

      params.each do |key, value|
        unless schema[key]
          schema["properties"][key] ||= {}
          scaffold_schema(schema["properties"][key], value)
        end
      end
    elsif params.kind_of? Array
      schema["type"] ||= "array"
      schema["items"] ||= {}
      params.each do |arr_value|
        scaffold_schema(schema["items"], arr_value)
      end
    else
      value = params
      schema["type"] ||= guess_type(params)
      if format = guess_format(params)
        schema["format"] ||= format
      end
      schema["example"] ||= value
    end

    unless options[:root_object]
      schema["description"] ||= "???"
      schema["required"] ||= "???"
    end
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
      "NilClass" => nil,
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

  def set_additional_properties_false_on(value)
    # default additionalProperties on objects to false
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
end
