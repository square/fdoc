class Fdoc::ParameterPresenter < Fdoc::HTMLPresenter
  include Fdoc
  def initialize(name, details, base_path, options = {})
    super nil, base_path, options
    @name = name
    @details = (details || {})
  end

  def as_html
    html = StringIO.new
    html << "<li class=\"#{css_classname}\">\n"
    html << " <tt>#{@name}</tt>\n" if @name
    html << " <span class=\"deprecated\">(deprecated)</span>\n" if deprecated?
    html << " #{HTMLPresenter.unpack_markdown description}\n" if description
    html << " <ul>\n"

    if (!type or type == "object") and title
      html << "    <li>Type: #{title}</li>\n"
    elsif type  and not properties
      html << "    <li>Type: #{type}</li>\n" if type
    end

    html << "    <li>Example: #{literal_as_html(example)}</li>\n" if example
    html << "    <li>Required: #{required? ? "yes" : "no"}</li>\n"
    html << "    <li>Default: #{literal_as_html(default)}</li>\n" if default

    (@details.keys - FORMATTED_KEYS).each do |additional_key|
      human_case = additional_key.gsub(/^[a-z]/) { |m| m.upcase }.gsub(/[a-z]([A-Z])/) { |m| " " + m }
      html << "   <li>#{human_case}: #{@details[additional_key]}</li>\n"
    end

    if properties
      properties.each do |name, properties|
        html << ParameterPresenter.new(name, properties, @base_path, @options).as_html
      end
    end

    if items
      html << "    <li>Items:<ul>\n"
      html << ParameterPresenter.new(nil, items, @base_path, @options).as_html
      html << "    </ul></li>\n"
    end
    html << "  </ul>"
    html << "</li>"
    html.string
  end

  def css_classname
    "parameter" + (deprecated? ? " deprecated" : "")
  end

  def literal_as_html(literal)
    return unless literal
    quote = (literal.kind_of? String or literal.kind_of? Time)
    "<tt>" +
    "#{"&quot;" if quote}" +
    "#{literal.to_s.gsub(/\"/, "&quot;")}" +
    "#{"&quot;" if quote}" +
    "</tt>"
  end

  FORMATTED_KEYS = %w(title required deprecated description default type example items properties)

  def required?
    @details["required"]
  end

  def title
    @details["title"]
  end

  def deprecated?
    @details["deprecated"]
  end

  def default
    @details["default"]
  end

  def description
    @details["description"]
  end

  def type
    @details["type"]
  end

  def example
    @details["example"]
  end

  def items
    @details["items"]
  end

  def properties
    @details["properties"]
  end
end
