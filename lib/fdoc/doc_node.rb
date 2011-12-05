=begin

Fdoc::Node is the abstract, meaning-free mapping tool. Within the realm of documentation, Fdoc::DocNode is the meaningful parent class.

Every node in the fdoc graph can take a description or be marked as deprecated.

=end

class Fdoc::DocNode < Fdoc::Node

map_keys_to_methods({
  "Description" => :description,
  "Deprecated" => :deprecated?
})

end