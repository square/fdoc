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

  def request?
    options[:request]
  end

  def nested?
    options[:nested]
  end

  def to_html
    html = StringIO.new

    html << '<span class="deprecated">Deprecated</span>' if deprecated?

    html << '<div class="schema">'
    html << render_markdown(@schema["description"])

    html << '<ul>'
    begin
      html << '<li>Type: %s</li>' % type if type
      html << '<li>Format: %s</li>' % format if format
      html << '<li>Required: %s</li>' % required? if nested?
      html << '<li>Example: %s</li>' % example if example
      html << enum_html

      (@schema.keys - FORMATTED_KEYS).each do |key|
        html << '<li>%s: %s</li>' % [ key, @schema[key] ]
      end

      html << items_html
      html << properties_html
    end


    html << '</ul>'
    html << '</div>'

    html.string
  end

  def type
    t = @schema["type"]
    if t.kind_of? Array
      t.join(", ")
    elsif t != "object"
      t
    end
  end

  def format
    @schema["format"]
  end

  def example
    e = @schema["example"]
    if e.kind_of? String
      '<tt>&quot;%s&quot;</tt>' % e.gsub(/\"/, 'quot;')
    elsif e.kind_of?(Numeric) || e.kind_of?(TrueClass) || e.kind_of?(FalseClass)
      '<tt>%s</tt>' % e
    elsif e.kind_of?(Hash) || e.kind_of?(Array)
      render_json(e)
    end
  end

  def deprecated?
    @schema["deprecated"]
  end

  def required?
    @schema["required"] ? "yes" : "no"
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
    items = @schema["items"]
    return unless items

    html = StringIO.new

    if items
      html << '<li>Items'

      if items.kind_of? Array
        item.each do |item|
          if item
            html << self.class.new(item, options.merge(:nested => true)).to_html
          end
        end
      else
        html << self.class.new(items, options.merge(:nested => true)).to_html
      end

      html << '</li>'
    end

    html.string
  end

  def properties_html
    properties = @schema["properties"]
    return unless properties

    html = StringIO.new

    properties.each do |key, property|
      next if property.nil?
      html << '<li>'
      html << '<tt>%s</tt>' % key
      html << self.class.new(property, options.merge(:nested => true)).to_html
      html << '</li>'
    end

    html.string
  end
end
