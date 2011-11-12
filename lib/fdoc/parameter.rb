class Fdoc::Parameter  < Fdoc::Node
  required_keys "Name", "Type"

  def required?
    raw["Required"]
  end

  def name
    raw["Name"]
  end

  def type
    raw["Type"]
  end

  def values
    raw["Values"]
  end
  
  def default
    raw["Default"]
  end

  def description
    raw["Description"]
  end

  def example
    raw["Example"]
  end
end