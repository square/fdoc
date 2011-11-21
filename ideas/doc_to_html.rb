require 'yaml'
require 'erb'
require '/Users/margolis/Development/fdoc/lib/fdoc'


class DirectoryPage
  def initialize(resources)
    @resources = resources
  end

  def get_binding
    binding
  end
end  

class ResourcePage
  def initialize(resource)
    @resource = resource
  end
  
  def get_binding
    binding
  end
end


if ARGV.length < 3
  abort "Usage: ruby doc_to_html.rb [fdoc_directory] [html_directory] [template_directory]"
end

fdoc_directory, html_directory, template_directory = ARGV[0..2]

directory_template = ERB.new(File.read(template_directory + "/directory.erb"))
resource_template = ERB.new(File.read(template_directory + "/resource.erb"))

resources = []

Dir.foreach(fdoc_directory) do |file|
  next unless file.end_with? ".fdoc"
  resource = Fdoc::Resource.build_from_file(fdoc_directory + "/#{file}")
  resources << resource 
  
  p = ResourcePage.new(resource)
  File.open(html_directory + "/#{file.gsub(/fdoc/, 'html')}", "w") { |f| f.write(resource_template.result(p.get_binding)) }
end


d = DirectoryPage.new(resources)
File.open(html_directory + "/index.html", "w") { |f| f.write(directory_template.result(d.get_binding)) }

