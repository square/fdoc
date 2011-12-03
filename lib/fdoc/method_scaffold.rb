class Fdoc::MethodScaffold

  attr_reader :scaffolded_method

  def initialize(method_name_or_method)
    if method_name_or_method.kind_of? Fdoc::Method
      @scaffolded_method = method_name_or_method
    else
      method_name = method_name_or_method.to_s
      @scaffolded_method = Fdoc::Method.new(:partial_data => {})
      @scaffolded_method.name = method_name.to_s
      @scaffolded_method.verb = "???"
      @scaffolded_method.description = "???"
    end
  end

  def scaffold_request(params)
    params.map do |key, value|
      unless @scaffolded_method.request_parameter_named(key)
        @scaffolded_method.request_parameters << scaffold_param(key, value, Fdoc::RequestParameter)
      end
    end
  end

  def scaffold_response(params, rails_response, successful)
    params.map do |key, value|
      unless @scaffolded_method.response_parameter_named(key)
        @scaffolded_method.response_parameters << scaffold_param(key, value, Fdoc::ResponseParameter)
      end
    end

    unless @scaffolded_method.response_code_for(rails_response, successful)
      rc = Fdoc::ResponseCode.new(:partial_data => {})
      rc.status = rails_response
      rc.successful = successful
      rc.description = "???"
      @scaffolded_method.response_codes << rc
    end
  end

  def scaffold_param(name, value, param_class)
    param = param_class.new(:partial_data => {})
    param.name = name.to_s
    param.type = guess_type(value)
    param.example = example_value(value)
    param.description = "???"

    if param_class == Fdoc::RequestParameter
      param.required = "???"
    end
    param
  end

  def example_value(value)
    if value.kind_of? String or value.kind_of? Numeric
      value
    elsif value.kind_of? Hash
      value.to_json
    else
      value.to_s
    end
  end

  def guess_type(value)
    in_type = value.class.to_s
    type_map = {
      "Fixnum" => "Integer",
      "Hash" => "Dictionary"
    }
    return type_map[in_type] || in_type
  end
end
