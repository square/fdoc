class Fdoc::Method < Fdoc::Node

  required_keys "Response Codes", "Verb", "Name"
  key_method_map({
    "Name" => :name,
    "Verb" => :verb,
    "Description" => :description
  })

  key_child_map({
    "Request Parameters" => [:request_parameters, Fdoc::RequestParameter],
    "Response Parameters" => [:response_parameters, Fdoc::ResponseParameter],
    "Response Codes" => [:response_codes, Fdoc::ResponseCode]
  })

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
