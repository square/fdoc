# BasePresenter for Fdoc::MetaService
class Fdoc::MetaServicePresenter < Fdoc::BasePresenter
  attr_reader :meta_service
  extend Forwardable

  def_delegators :meta_service, :name, :meta_service_dir

  def initialize(meta_service, options = {})
    super(options)
    @meta_service = meta_service
  end

  def name
    meta_service.name
  end

  def to_html
    render_erb('meta_service.html.erb')
  end

  def to_markdown
    render_erb('meta_service.md.erb')
  end

  def services
    @services ||= meta_service.services.
      sort_by(&:name).
      map do |service|
        Fdoc::ServicePresenter.new(service, options)
      end
  end

  def endpoints
    if !@endpoints
      @endpoints = []
      prefix = nil

      ungrouped_endpoints.each do |endpoint|
        presenter = presenter_from_endpoint(endpoint)
        current_prefix = presenter.prefix

        @endpoints << [] if prefix != current_prefix
        @endpoints.last << presenter

        prefix = current_prefix
      end
    end

    @endpoints
  end

  def description(options = {:render => true})
    options[:render] ? render_markdown(meta_service.description) : meta_service.description
  end

  def discussion(options = {:render => true})
    options[:render] ? render_markdown(meta_service.discussion) : meta_service.discussion
  end

  def relative_service_path(service_presenter, file_name = nil)
    service_path = service_presenter.slug_name
    if file_name
      service_path = File.join(service_path, file_name)
    end
    service_path
  end

  private

  def ungrouped_endpoints
    meta_service.services.
                 map(&:endpoints).
                 flatten.
                 sort_by(&:endpoint_path)
  end

  def presenter_from_endpoint(endpoint)
    service_presenter = Fdoc::ServicePresenter.new(endpoint.service)

    presenter = Fdoc::EndpointPresenter.new(endpoint,
      options.merge(:prefix => (service_presenter.slug_name + "/")))
    presenter.service_presenter = service_presenter
    presenter
  end
end
