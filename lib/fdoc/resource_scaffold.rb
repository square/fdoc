class Fdoc::ResourceScaffold
  attr_reader :scaffolded_resource

  def initialize(controller_name_or_resource)
    if controller_name_or_resource.kind_of? String
      controller_name = controller_name_or_resource
      @scaffolded_resource = Fdoc::Resource.new(:partial_data => {})
      @scaffolded_resource.name = guess_resource_name(controller_name)
      @scaffolded_resource.controller = controller_name
      @scaffolded_resource.description = "???"
      @scaffolded_resource.base_path = "???"
    elsif controller_name_or_resource.kind_of? Fdoc::Resource
      @scaffolded_resource = controller_name_or_resource
    end
  end

  def self.create_or_load(controller_name, path = "/tmp/")
    filename = File.join(path, scaffold_filename(guess_resource_name(controller_name)))
    if File.exists? filename
      scaffold = new Fdoc::Resource.build_from_file(filename)
    else
      scaffold = new controller_name
    end
    scaffold
  end

  def add_method_scaffold(action)
    method_scaffold = Fdoc::MethodScaffold.new(action || "???")
    @scaffolded_resource.actions << method_scaffold
    method_scaffold
  end

  def write_to_directory(path = "/tmp/")
    File.open(File.join(path, scaffold_filename(@scaffolded_resource.name)), 'w') do |f|
      YAML.dump(@scaffolded_resource.as_hash, f)
    end
  end
  
  def guess_resource_name(controller_name)
    camel_case_resource = controller_name.split(':').last.match(/(.*)(?:Controller?)/)[1]
    snake_case_resource = camel_case_resource.gsub(/^([A-Z])/) {|m| m.downcase}.gsub(/([A-Z])/) {|m| "_#{m.downcase}" }
  end
  
  def scaffold_filename(resource_name)
    "#{resource_name}.fdoc.scaffold"
  end
end
