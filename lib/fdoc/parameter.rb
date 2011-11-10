class Fdoc::Parameter  < Fdoc::Node
  required_keys "Name", "Type"

  def name
    raw["Name"]
  end

  def type
    raw["Type"]
  end

  def required?
    raw["Required"]
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

  # TODO: don't document this here, document it in a real place
  # this is where you describe limits on the values
  # could be possible values (like for an enum), or some description about the range.
  def values
    raw["Values"]
  end
end