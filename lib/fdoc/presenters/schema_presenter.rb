# An HtmlPresenter for a JSON Schema fragment. Like most JSON
# schema things, has a tendency to recurse.
class Fdoc::SchemaPresenter < Fdoc::HtmlPresenter
  FORMATTED_KEYS = %w(
    description
    type
    required
    example
    deprecated
    default
    format
    enum
    items
    properties
  )

  def initialize(schema, options)
    super(options)
    @schema = schema
  end

  # Attribute Helpers

  def format
    @schema["format"]
  end

  def request?
    options[:request]
  end

  def nested?
    options[:nested]
  end

  def deprecated?
    @schema["deprecated"]
  end

  def required?
    @schema["required"]
  end

  def unformatted_keys
    @schema.keys - FORMATTED_KEYS
  end

  def schema_slug(key, property)
    "#{key}-#{property.hash}"
  end

  def example
    return unless e = @schema["example"]
    render_json(e)
  end

  # Builders

  def to_html
    build do |output|
      output.tag(:span, 'Deprecated', :class => 'deprecated') if deprecated?
      output.tag(:div, :class => 'schema') do |schema|
        schema.puts render_markdown(@schema["description"])
        schema.tag(:ul) do |list|
          list.tag(:li, "Required: #{required?  ? 'yes' : 'no'}") if nested?
          list.tag(:li, "Type: #{type}") if type
          list.tag(:li, "Format: #{format}") if format
          list.tag(:li, "Example: #{example}") if example
          list.puts(enum_html)

          unformatted_keys.each do |key|
            list.tag(:li, "#{key}: #{@schema[key]}")
          end

          list.puts(items_html)
          list.puts(properties_html)
        end
      end
    end
  end

  def type
    t = @schema["type"]
    if t.kind_of? Array
      types = t.map do |type|
        if type.kind_of? Hash
          '<li>%s</li>' % self.class.new(type, options).to_html
        else
          '<li>%s</li>' % type
        end
      end.join('')

      '<ul>%s</ul>' % types
    elsif t != "object"
      t
    end
  end

  def enum_html
    enum = @schema["enum"]
    return unless enum

    list = enum.map do |e|
      '<tt>%s</tt>' % e
    end.join(", ")

    html = StringIO.new
    html << '<li>Enum: '
    html << list
    html << '</li>'
    html.string
  end

  def items_html
    return unless items = @schema["items"]

    html = ""
    html << '<li>Items'

    sub_options = options.merge(:nested => true)

    if items.kind_of? Array
      item.compact.each do |item|
        html << self.class.new(item, sub_options).to_html
      end
    else
      html << self.class.new(items, sub_options).to_html
    end

    html << '</li>'
    html
  end

  def properties_html
    return unless properties = @schema["properties"]

    html = ""

    properties.each do |key, property|
      next if property.nil?
      html << '<li>'
      html << tag_with_anchor(
        'span',
        '<tt>%s</tt>' % key,
        schema_slug(key, property)
      )
      html << self.class.new(property, options.merge(:nested => true)).to_html
      html << '</li>'
    end

    html
  end

end
