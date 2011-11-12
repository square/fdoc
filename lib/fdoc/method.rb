class Fdoc::Method < Fdoc::Node

  attr_reader :raw, :request_parameters, :response_parameters, :response_codes
  required_keys "Response Codes", "Verb", "Name"

  def initialize(data)
    super
    @request_parameters = (raw["Request Parameters"] || []).map { |param_data| Fdoc::RequestParameter.new(param_data) }
    @response_parameters = (raw["Response Parameters"] || []).map { |param_data| Fdoc::ResponseParameter.new(param_data) }
    @response_codes = raw["Response Codes"].map { |response_data| Fdoc::ResponseCode.new(response_data) }
  end

  def name
    raw["Name"]
  end

  def verb
    raw["Verb"]
  end

  def description
    raw["Description"]
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