# An HtmlPresenter for Fdoc::Service
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
    if !@endpoints
      @endpoints = []
      prefix = nil

      service.endpoints.sort_by(&:endpoint_path).map do |endpoint|
        presenter = Fdoc::EndpointPresenter.new(endpoint, options)

        current_prefix = presenter.prefix

        @endpoints << [] if prefix != current_prefix
        @endpoints.last << presenter

        prefix = current_prefix
        presenter
      end
    end

    @endpoints
  end

  def description
    render_markdown(service.description)
  end
end
