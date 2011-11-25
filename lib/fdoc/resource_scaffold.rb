class Fdoc::ResourceScaffold
  attr_reader :scaffolded_resource

  def initialize(controller_name)    
    @scaffolded_resource = Fdoc::Resource.new(:partial_data => {})
    camel_case_resource = controller_name.split(':').last.match(/(.*)(?:Controller?)/)[1]
    snake_case_resource = camel_case_resource.gsub(/^([A-Z])/) {|m| m.downcase}.gsub(/([A-Z])/) {|m| "_#{m.downcase}" }
    @scaffolded_resource.name = snake_case_resource
    @scaffolded_resource.controller = controller_name
    @scaffolded_resource.description = "???"
    @scaffolded_resource.base_path = "???"
  end

  alias create_or_load initialize

  def add_method_scaffold(action)
    method_scaffold = Fdoc::MethodScaffold.new(action || "???")
    @scaffolded_resource.actions << method_scaffold
    method_scaffold
  end

  def write_to_directory(path = "/tmp/")
    File.open(File.join(path, "#{@scaffolded_resource.name}.fdoc.scaffold"), 'w') do |f|
      YAML.dump(@scaffolded_resource.as_hash, f)
    end
  end
end
