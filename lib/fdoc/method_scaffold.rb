class Fdoc::MethodScaffold
  def initialize(method_name)
    @scaffolded_method = Fdoc::Method.new(:partial_data => {"Name" => method_name.to_s})
  end

  def scaffold_param(name, value, param_class)
    data = {}
    data["Name"] => name
    data["Type"] = value.class.to_s + "?"
    data["Example"] = value
    data["Description"] = "???"

    data.description = "???"

    if param_class == Fdoc::RequestParameter
      data["Required"] = "???"
    end

    param_class.new(:partial_data => data)
  end

  def scaffold_request(params)
    params.map do |key, value|
      unless @scaffolded_method.request_parameter_named(key)
        @scaffolded_method.request_parameters << scaffold_parameter(key, value, Fdoc::RequestParameter)
      end
    end
  end

  def scaffold_response(params, rails_response, successful)
    params.map do |key, value|
      unless @scaffolded_method.response_parameter_named(key)
        @scaffolded_method.response_parameters << scaffold_parameter(key, value, Fdoc::ResponseParameter)
      end
    end

    unless @scaffolded_method.response_code_for(rails_response, successful)
      data = {}
      data["Response Code"] = rails_response
      data["Successful"] = successful
      @scaffolded_method.response_codes << Fdoc::ResponseCode.new(:partial_data => data)
    end
  end
end
