# An HtmlPresenter for a JSON Schema fragment. Like most JSON
# schema things, has a tendency to recurse.
class Fdoc::SchemaPresenter < Fdoc::HtmlPresenter
  FORMATTED_KEYS = %w(
    description
    type
    required
    deprecated
    default
    format
    example
    enum
    items
    properties
  )

  def initialize(schema, options)
    super(options)
    @schema = schema
  end

  # Attribute Helpers

  def description
    @schema["description"]
  end

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

  # Builders

  def to_html
    html do |output|
      output.tag(:span, 'Deprecated', :class => 'deprecated') if deprecated?
      output.tag(:div, :class => 'schema') do |schema|
        schema.tag(:ul) do |list|
          unformatted_keys.each do |key|
            list.tag(:li, "#{key}: #{@schema[key]}")
          end

          list.puts(enum_html)
          list.puts(items_html)
          list.puts(properties_html)
        end
      end
    end
  end

  def type_html
    if type.kind_of?(Array)
      html do |output|
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

    html do |output|
      output.tag(:li, "Enum: #{list}")
    end
  end

  def items_html
    return unless items = @schema["items"]

    html do |output|
      output.tag(:li) do
        sub_options = options.merge(:nested => true)

        if items.kind_of?(Array)
          items.compact.map do |item|
            self.class.new(item, sub_options).to_html
          end.join
        else
          self.class.new(items, sub_options).to_html
        end
      end
    end
  end

  def properties_html
    return unless properties = @schema["properties"]

    html do |output|
      properties.each do |key, property|
        next if property.nil?

        schema = self.class.new(property, options.merge(:nested => true))

        output.tag(:li) do |t|
          tags = html do |tags|
            tags.tag(:span, "required", :class => 'required') if schema.nested? && schema.required?
            tags.puts " "
            tags.tag(:span, "#{schema.format}", :class => 'format') if schema.format
            tags.puts " "
            tags.tag(:span, "#{schema.type_html}", :class => 'type') if schema.type_html
          end

          t.puts(tag_with_anchor('span', "<tt>%s</tt> - #{schema.description} #{tags}" % key, schema_slug(key, property)))
          t.puts(schema.to_html)
        end
      end
    end
  end

end
