require 'erb'
require 'redcarpet'

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
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      :space_after_headers => true)
    if markdown_str
      @markdown.render(markdown_str)
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

  def index_path
    if options[:static_html]
      File.join(html_directory, 'index.html')
    else
      html_directory
    end
  end
end
