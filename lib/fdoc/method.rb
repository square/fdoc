class Fdoc::Method < Fdoc::Node

  required_keys "Response Codes", "Verb", "Name"
  map_keys_to_methods({
    "Name" => :name,
    "Verb" => :verb,
    "Description" => :description
  })

  map_keys_to_children({
    "Request Parameters" => [:request_parameters, Fdoc::RequestParameter],
    "Response Parameters" => [:response_parameters, Fdoc::ResponseParameter],
    "Response Codes" => [:response_codes, Fdoc::ResponseCode]
  })

  def request_parameter_named(name)
    request_parameters.find {|p| p.name == name.to_s}
  end

  def response_parameter_named(name)
    response_parameters.find {|p| p.name == name.to_s}
  end

  def response_code_for(status, successful)
    response_codes.find {|r| r.status == status and r.successful? == successful}
  end

  def required_request_parameters
    @request_parameters.select { |p| p.required? }
  end

  def optional_request_parameters
    @request_parameters.select { |p| !p.required? }
  end

  def required_response_parameters
    @response_parameters.select { |p| p.required? }
  end

  def optional_response_parameters
    @response_parameters.select { |p| !p.required? }
  end

  def successful_response_codes
    @response_codes.select { |r| r.successful? }
  end

  def failure_response_codes
    @response_codes.select { |r| !r.successful? }
  end
end
