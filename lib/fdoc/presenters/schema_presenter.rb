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
      html << '<li>Required: %s</li>' % required? if nested?
      html << '<li>Type: %s</li>' % type if type
      html << '<li>Format: %s</li>' % format if format
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

  def to_markdown(prefix = "")
    md = StringIO.new
    md << 'Deprecated' if deprecated?
    md << "\n#{@schema["description"]}"
    md << "\n#{prefix}* __Required__: #{required?}" if nested?
    md << "\n#{prefix}* __Type__: #{type}" if type
    md << "\n#{prefix}* __Format__: #{format}" if format
    md << "\n#{prefix}* __Example__: <tt>#{example.to_markdown}</tt>" if example
    md << "\n#{@schema['enum']}"
    (@schema.keys - Fdoc::SchemaPresenter::FORMATTED_KEYS).each do |key|
      md << "\n#{prefix}* %{key} %{@schema[key]}"
    end
    if items = @schema["items"]
      md << "\n#{prefix}* Items"
      if items.kind_of? Array
        item.compact.each do |item|
          md << Fdoc::SchemaPresenter.new(item, options.merge(nested: true)).to_markdown(prefix + "\t")
        end
      else
        md << Fdoc::SchemaPresenter.new(@schema["items"], options.merge(nested: true)).to_markdown(prefix + "\t")
      end
    end
    if properties = @schema["properties"]
      properties.each do |key, property|
        next if property.nil?
        md << "\n#{prefix}* __#{key}__:"
        md << Fdoc::SchemaPresenter.new(property, options.merge(nested: true)).to_markdown(prefix + "\t")
      end
    end
    md.string
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

  def format
    @schema["format"]
  end

  def example
    return unless e = @schema["example"]

    Fdoc::JsonPresenter.new(e)
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

  def schema_slug(key, property)
    "#{key}-#{property.hash}"
  end
end
