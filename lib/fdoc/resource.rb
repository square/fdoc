class Fdoc::Resource < Fdoc::Node

  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end

  attr_reader :actions
  def initialize(data)
    super
    @actions = raw["Methods"].map { |method| Fdoc::Action.new(method) }
  end
  
  def name
    raw["Resource Name"]
  end
  
  def action(action_symbol)
    actions.detect { |a| a.name.downcase.to_sym == action_symbol }
  end
end