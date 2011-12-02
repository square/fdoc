class Fdoc::Parameter  < Fdoc::Node
  required_keys "Name", "Type"
  map_keys_to_methods ({
    "Name" => :name,
    "Type" => :type,
    "Values" => :values,
    "Default" => :default,
    "Description" => :description,
    "Required" => :required?,
    "Example" => :example
  })

end
