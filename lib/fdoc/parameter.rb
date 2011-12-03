class Fdoc::Parameter  < Fdoc::DocNode
  required_keys "Name", "Type"
  map_keys_to_methods ({
    "Name" => :name,
    "Type" => :type,
    "Values" => :values,
    "Default" => :default,
    "Required" => :required?,
    "Example" => :example
  })

end
