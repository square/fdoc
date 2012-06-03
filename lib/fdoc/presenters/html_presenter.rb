require 'erb'
require 'kramdown'

class Fdoc::HtmlPresenter
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def render_erb(erb_name)
    template_path = File.join(File.dirname(__FILE__), "../templates", erb_name)
    template = ERB.new(File.read(template_path))
    template.result(binding)
  end

  def render_markdown(markdown_str)
    if markdown_str
      Kramdown::Document.new(markdown_str, :entity_output => :numeric).to_html
    else
      nil
    end
  end

  def render_json(json)
    '<pre><code>%s</code></pre>' % JSON.pretty_generate(json)
  end

  def html_directory
    options[:url_base_path] || options[:html_directory] || ""
  end

  def css_path
    File.join(html_directory, "styles.css")
  end

  def index_path(subdirectory = "")
    html_path = File.join(html_directory, subdirectory)
    if options[:static_html]
      File.join(html_path, 'index.html')
    else
      html_path
    end
  end
end
