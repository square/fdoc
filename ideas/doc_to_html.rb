require 'yaml'
require 'erb'


if ARGV.length < 2
  abort "Usage: ruby doc_to_html.rb [fdoc_input] [html_output] (template=resource.erb)"
end

fdoc_input, html_output, template_location = ARGV[0..2]
template_location ||= 'resource.erb'

class Page
  def initialize(resource)
    @resource = resource
  end
  
  def get_binding
    binding
  end
end

template = ERB.new(File.read(template_location))
p = Page.new(YAML.load_file(fdoc_input))

File.open(html_output, "w") { |f| f.write(template.result(p.get_binding)) }

