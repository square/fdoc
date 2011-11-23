class Fdoc::Resource < Fdoc::Node

  attr_reader :actions
  required_keys "Controller", "Resource Name", "Methods"
  key_method_map {
    "Resource Name" => :name,
    "Controller" => :controller,
    "Base Path" => :base_path,
    "Description" => :description
  }

  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end

  def initialize(data)
    super
    @actions = raw["Methods"].map { |method| Fdoc::Method.new(method) }
  end

  def action(action_name)
    actions.detect { |a| a.name == action_name }
  end
end