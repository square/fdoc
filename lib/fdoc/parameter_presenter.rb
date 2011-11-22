class Fdoc::ParameterPresenter < Fdoc::Presenter

  def as_html
    template = ERB.new <<-EOF
      <li class="parameter <%= "deprecated" if node.deprecated? %>">
        <%= "<tt>#{node.name}</tt>" %>
        <%= "<span class=\\"deprecated\\">(deprecated)</span>" if node.deprecated? %>
        <%= "<p>#{node.description}</p>" if node.description %>
        <ul>
          <%= "<li>Type: #{node.type}</li>" if node.type %>
          <%= "<li>Values: #{values_as_html}</li>" if node.values %>
          <%= "<li>Default: <tt>#{node.default}</tt></li>" if node.default %>
          <%= "<li>Description: #{node.description}</li>" if node.description %>
          <%= "<li>Example: #{example_as_html}</li>" if node.example %>          
        </ul>
      </li>
    EOF
    template.result(binding)
  end
  
  def values_as_html
    return unless node.values and node.type
    
    if node.type.downcase == "enum"
      return "#<tt>&quot;{node.values.join(\"&quot;, &quot\")}&quot;</tt>"
    end
  end
  
  def example_as_html
    "<tt>#{node.example}</tt>"
  end
end