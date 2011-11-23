class Fdoc::ResponseCode < Fdoc::Node
  required_keys "Status", "Successful"

  key_method_map ({
    "Status" => :status,
    "Successful" => :successful?,
    "Sample Output" => :sample_output,
    "Description" => :description
  })

end