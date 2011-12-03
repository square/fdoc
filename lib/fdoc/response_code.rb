class Fdoc::ResponseCode < Fdoc::DocNode
  required_keys "Status", "Successful"

  map_keys_to_methods ({
    "Status" => :status,
    "Successful" => :successful?,
    "Sample Output" => :sample_output,
  })

end
