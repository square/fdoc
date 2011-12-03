class Fdoc::Resource < Fdoc::Node

  required_keys "Controller", "Resource Name", "Methods"
  map_keys_to_methods ({
    "Resource Name" => :name,
    "Controller" => :controller,
    "Base Path" => :base_path,
    "Description" => :description
  })
  map_keys_to_children ({
    "Methods" => [:actions, Fdoc::Method]
  })

  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end

  def action_named(action_name)
    actions.detect { |a| a.name == action_name.to_s }
  end
end
