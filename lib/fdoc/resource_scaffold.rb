class Fdoc::ResourceScaffold
  def self.scaffold_resource(controller_name)
    scaffolded_resource = Fdoc::Resource.new(:partial_data => {})
    scaffolded_resource.name = guess_resource_name(controller_name)
    scaffolded_resource.controller = controller_name
    scaffolded_resource.description = "???"
    scaffolded_resource.base_path = "???"
    scaffolded_resource
  end

  def self.write_to_directory(resource, path = "docs/fdoc")
    filename = "#{resource.name}.fdoc"
    unless File.exist? File.join(path, filename)
      filename = "#{resource.name}.fdoc.scaffold"
    end

    File.open(File.join(path, filename), 'w') do |f|
      YAML.dump(resource.as_hash, f)
    end
  end

  def self.guess_resource_name(controller_name)
    camel_case_resource = controller_name.split(':').last.match(/(.*)(?:Controller?)/)[1]
    snake_case_resource = camel_case_resource.gsub(/^([A-Z])/) {|m| m.downcase}.gsub(/([A-Z])/) {|m| "_#{m.downcase}" }
  end
end
