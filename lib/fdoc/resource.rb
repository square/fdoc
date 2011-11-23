class Fdoc::Resource < Fdoc::Node

  required_keys "Controller", "Resource Name", "Methods"
  key_method_map ({
    "Resource Name" => :name,
    "Controller" => :controller,
    "Base Path" => :base_path,
    "Description" => :description
  })
  key_child_map ({
    "Methods" => [:actions, Fdoc::Method]
  })

  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end

  def action(action_name)
    actions.detect { |a| a.name == action_name }
  end
end