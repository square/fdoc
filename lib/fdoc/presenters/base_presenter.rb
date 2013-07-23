require 'erb'
require 'kramdown'
require 'json'
require 'forwardable'

# BasePresenters assist in generating Html for fdoc classes.
# BasePresenters is an abstract class with a lot of helper methods
# for URLs and common text styling tasks (like #render_markdown
# and #render_json)
class Fdoc::BasePresenter
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def render_erb(erb_name, binding = get_binding)
    template_path = File.join(options[:template_directory], erb_name)
    if !File.exists? template_path
      template_path = File.join(File.dirname(__FILE__), "../templates", erb_name)
    end
    template = ERB.new(File.read(template_path), nil, '-')
    template.result(binding)
  end

  def render_markdown(markdown_str)
    if markdown_str
      Kramdown::Document.new(markdown_str, :entity_output => :numeric).to_html
    else
      nil
    end
  end

  def get_binding
    binding
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

  def tag_with_anchor(tag, content, anchor_slug = nil)
    anchor_slug ||= content.downcase.gsub(' ', '_')
    <<-EOS
    <#{tag} id="#{anchor_slug}">
      <a href="##{anchor_slug}" class="anchor">
        #{content}
      </a>
    </#{tag}>
    EOS
  end
end
