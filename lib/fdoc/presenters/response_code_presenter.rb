# An BasePresenter for ResponseCodes
class Fdoc::ResponseCodePresenter < Fdoc::BasePresenter
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

  def to_markdown
    "__#{status}__: #{description_raw}"
  end

  def successful?
    response_code["successful"]
  end

  def status
    response_code["status"]
  end

  def description
    render_markdown(description_raw)
  end

  def description_raw
    response_code["description"]
  end

end
