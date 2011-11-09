class Fdoc::Resource < Fdoc::Node

  attr_reader :actions
  required_keys "Controller", "Resource Name", "Methods"

  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end

  def initialize(data)
    super
    @actions = raw["Methods"].map { |method| Fdoc::Action.new(method) }
  end
  
  def name
    raw["Resource Name"]
  end

  def controller
    raw["Controller"]
  end
  
  def action(action_name)
    actions.detect { |a| a.name == action_name }
  end
end