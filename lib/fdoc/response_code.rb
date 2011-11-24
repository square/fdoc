class Fdoc::ResponseCode < Fdoc::Node
  required_keys "Status", "Successful"

  map_keys_to_methods ({
    "Status" => :status,
    "Successful" => :successful?,
    "Sample Output" => :sample_output,
    "Description" => :description
  })

end
