class Fdoc::MethodPresenter < Fdoc::Presenter

  attr_reader :resource

  def initialize(node, resource)
    super node
    @resource = resource
  end

  def name_as_html
    template = ERB.new <<-EOF
      <span class="verb"><%= node.verb.strip %></span>
      <span class="base-path"><%= resource.base_path.strip %></span><span class="name">/<%= node.name.strip %></span>
    EOF
    template.result(binding)
  end
end
