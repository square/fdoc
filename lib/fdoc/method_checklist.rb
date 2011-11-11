class Fdoc::MethodChecklist
  def initialize(method)
    @method = method
  end

  def consume_request_parameters(params)
    params = stringify_keys(params)

    @method.required_request_parameters.each do |parameter|
      unless params.has_key? parameter.name
        raise Fdoc::MissingRequiredParameterError, "Looking for request parameter '#{parameter.name}' in #{@method.verb} #{@method.name}"
      end
    end

    validate_documented(params, @method.request_parameters, "request")
    true
  end

  def consume_response(params, rails_response, successful = true)
    response_codes =  @method.response_codes.select { |rc| rc.status == rails_response }

    if response_codes.empty?
      raise Fdoc::UndocumentedResponseCodeError, "Received code '#{rails_response}' in #{@method.verb} #{@method.name}"
    end

    response_codes = response_codes.select { |rc| successful == rc.successful? }

    if response_codes.empty?
      if successful
        message = "as a successful result, but it was documented as failed."
      else
        message = "as a failed result, but it was documented as successful."
      end
      raise Fdoc::UndocumentedResponseCodeError, "Received code '#{rails_response}' in #{@method.verb} #{@method.name} #{message}"
    end

    validate_documented(params, @method.response_parameters, "response") if successful
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

  def validate_documented(test, definition, request_or_response)
    test.each do |param_name, value|
      unless definition.map(&:name).include?(param_name)
        raise Fdoc::UndocumentedParameterError, "Extra #{request_or_response} parameter '#{param_name}' in #{@method.verb} #{@method.name}"
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
