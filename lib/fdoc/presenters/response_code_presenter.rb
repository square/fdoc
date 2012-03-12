class Fdoc::ResponseCodePresenter < Fdoc::HtmlPresenter
  attr_reader :response_code

  def initialize(response_code, options)
    super(options)
    @response_code = response_code
  end

  def to_html
    <<-EOS
    <div class="response-code">
    <span class="status">
      #{status}
    </span>
    #{description}
    </div>
    EOS
  end

  def successful?
    @response_code["successful"]
  end

  def status
    @response_code["status"]
  end

  def description
    render_markdown(@response_code["description"])
  end
end