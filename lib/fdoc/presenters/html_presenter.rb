require 'erb'
require 'kramdown'
require 'json'

# HtmlPresenters assist in generating Html for fdoc classes.
# HtmlPresenters is an abstract class with a lot of helper methods
# for URLs and common text styling tasks (like #render_markdown
# and #render_json)
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
    if json.kind_of? String
      '<tt>&quot;%s&quot;</tt>' % json.gsub(/\"/, 'quot;')
    elsif json.kind_of?(Numeric) ||
          json.kind_of?(TrueClass) ||
          json.kind_of?(FalseClass)
      '<tt>%s</tt>' % json
    elsif json.kind_of?(Hash) ||
          json.kind_of?(Array)
      '<pre><code>%s</code></pre>' % JSON.pretty_generate(json)
    end
  end

  class HTMLBuilder

    def initialize(options = {})
      @options = options.dup
      @buffer  = []

      yield self if block_given?
    end

    def tag(name, *args)
      if block_given?
        options = args.pop || {}
        builder = self.class.new
        yield(builder)
        content = builder.render
      else
        content = args.shift
        options = args.shift || {}
      end

      @buffer << %{<#{name}#{format_options(options)}>#{content}</#{name}>}
    end

    def puts(*args)
      @buffer << args.join
    end

    def render
      @buffer.join
    end

  protected

    def format_options(hash)
      return "" if hash.empty?

      attributes = hash.map do |attribute, value|
       %{#{attribute}="#{value}"}
      end

      %{ #{attributes.join(' ')}}
    end

  end

  def html(*args, &block)
    HTMLBuilder.new(*args, &block).render
  end

  def html_directory
    options[:url_base_path] || options[:html_directory] || ""
  end

  def css_path
    File.join(html_directory, "application.css")
  end

  def js_path
    File.join(html_directory, "application.js")
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
