class Fdoc::ServicePresenter < Fdoc::HtmlPresenter
  attr_reader :service

  def initialize(service, options = {})
    super(options)
    @service = service
  end

  def to_html
    render_erb('service.html.erb')
  end

  def endpoints
    @endpoints ||= service.endpoints.map do |endpoint|
      Fdoc::EndpointPresenter.new(endpoint, options)
    end
  end

  def description
    render_markdown(service.description)
  end
end
