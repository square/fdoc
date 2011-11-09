class Fdoc::Action < Fdoc::Node
  
  attr_reader :raw, :parameters, :responses
  required_keys "Responses", "Verb", "Name"
  
  def initialize(data)
    super
    @parameters = (raw["Parameters"] || []).map { |param_data| Fdoc::Parameter.new(param_data) }
    @responses = (raw["Responses"] || []).map { |response_data| Fdoc::Response.new(response_data) }
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
  
  def required_parameters
    @parameters.select { |p| p.required? }
  end

  def optional_parameters
    @parameters.select { |p| !p.required? }
  end

  def success_responses
    @responses.select { |r| r.successful? }
  end
  
  def failure_responses
    @responses.select { |r| !r.successful? }
  end
end