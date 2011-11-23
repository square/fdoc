class Fdoc::Parameter  < Fdoc::Node
  required_keys "Name", "Type"
  key_method_map ({
    "Name" => :name,
    "Type" => :type,
    "Values" => :values,
    "Default" => :default,
    "Description" => :description,
    "Required" => :required?,
    "Example" => :example
  })

end