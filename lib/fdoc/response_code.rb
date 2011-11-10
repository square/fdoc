class Fdoc::ResponseCode < Fdoc::Node
  required_keys "Status", "Successful"

  def status
    raw["Status"]
  end

  def successful?
    raw["Successful"]
  end

  def sample_output
    raw["Sample Output"]
  end

  def description
    raw["Description"]
  end
end