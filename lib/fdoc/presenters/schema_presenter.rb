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

  def type
    @schema["type"]
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
          list.tag(:li, "Type: #{type_html}") if type_html
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

  def type_html
    if type.kind_of?(Array)
      build do |output|
        output.tag(:ul) do |list|
          type.each do |t|
            if t.kind_of?(Hash)
              list.tag(:li, self.class.new(t, options).to_html)
            else
              list.tag(:li, t)
            end
          end
        end
      end
    elsif type != "object"
      type
    end
  end

  def enum_html
    return unless enum = @schema["enum"]

    list = enum.map do |e|
      "<tt>#{e}</tt>"
    end.join(", ")

    build do |output|
      output.tag(:li, "Enum: #{list}")
    end
  end

  def items_html
    return unless items = @schema["items"]

    build do |output|
      output.tag(:li) do
        sub_options = options.merge(:nested => true)

        if items.kind_of?(Array)
          item.compact.each do |item|
            html = self.class.new(item, sub_options).to_html
          end
        else
          html = self.class.new(items, sub_options).to_html
        end

        %{Items #{html}}
      end
    end
  end

  def properties_html
    return unless properties = @schema["properties"]

    build do |output|
      properties.each do |key, property|
        next if property.nil?

        output.tag(:li) do |t|
          t.puts(tag_with_anchor('span', '<tt>%s</tt>' % key, schema_slug(key, property)))
          t.puts(self.class.new(property, options.merge(:nested => true)).to_html)
        end
      end
    end
  end

end
