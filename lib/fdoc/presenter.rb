class Fdoc::Presenter
  
  attr_reader :node
  
  def initialize(node)
    @node = node
  end
  
  def as_html
    ""
  end
end

