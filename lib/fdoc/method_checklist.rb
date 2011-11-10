class Fdoc::MethodChecklist
  def initialize(method)
    @method = method
  end

  def consume_request_parameters(params)
    params = stringify_keys(params)

    @method.required_request_parameters.each do |parameter|
      unless params.has_key? parameter.name
        raise Fdoc::MissingRequiredParameterError, "Looking for parameter: #{parameter.name}"
      end
    end

    validate_documented(params, @method.request_parameters)
    true
  end

  def consume_response_parameters(params)
    validate_documented(params, @method.response_parameters)
    true
  end

  def consume_response_code(rails_response)
    unless @method.response_codes.map(&:status).include?(rails_response)
      raise Fdoc::UndocumentedResponseCodeError, "Received code: #{rails_response}"
    end
    true
  end

  private

  def stringify_keys(value)
    return value unless value.is_a?(Hash)
    result =  {}

    value.each do |k, v|
      result[k.to_s] = stringify_keys(v)
    end

    result
  end

  def validate_documented(test, definition)
    test.each do |param_name, value|
      unless definition.map(&:name).include?(param_name)
        raise Fdoc::UndocumentedParameterError, "Extra parameter: #{param_name}"
      end
    end
  end
  # params.each { |param_name, value|
  #   if @optional_params_used.has_key? param_name
  #     next # already used, just continue
  #   elsif @optional_params_unused.has_key? param_name
  #     # first use: move the parameter from unused to used
  #     @optional_params_used[param_name] = @optional_params_unused[param_name]
  #     @optional_params_unused.delete param_name
  #   else
  #   end
  # }
end
