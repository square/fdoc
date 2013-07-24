require 'thor'
require 'fdoc/service'
require 'fdoc/meta_service'

module Fdoc
  # A Thor::Error to be thrown when an fdoc directory is not found
  class NotFound < Thor::Error; end

  # A Thor::Error to be thrown when an fdoc output destination is unavailable
  class NotADirectory < Thor::Error; end

  # A Thor definition for an fdoc to HTML conversion operation
  class Cli < Thor
    include Thor::Actions

    attr_accessor :origin_path

    def self.source_root
      File.expand_path("../templates", __FILE__)
    end

    desc "convert FDOC_PATH", "Convert fdoc to HTML or Markdowns"
    method_option :output, :aliases => "-o", :desc => "Output path"
    method_option :url_base_path, :aliases => "-u", :desc => "URL base path"
    method_option :format, :aliases => "-f", :desc => "Format in html or markdown, defaults to html", :default => "html"
    method_option :templates, :aliases => "-t", :desc => "Template overrides path"
    def convert(fdoc_path)
      say_status nil, "Converting fdoc to #{options[:format]}"

      self.origin_path = File.expand_path(fdoc_path)
      raise Fdoc::NotFound.new(origin_path) unless has_valid_origin?
      say_status :using, fdoc_path

      self.destination_root = output_path
      raise Fdoc::NotADirectory.new(output_path) unless has_valid_destination?
      say_status :inside, output_path

      if options[:format] == 'markdown'
        convert_to_markdown
      else
        convert_to_html
      end
    end

    no_tasks do
      def convert_to_html
        in_root do
          copy_file("styles.css")
          create_file("index.html", meta_presenter.to_html) if has_meta_service?
        end

        service_presenters.each do |service_presenter|
          inside_service_presenter(service_presenter) do
            create_file("index.html", service_presenter.to_html)

            service_presenter.endpoints.each do |endpoint_prefix_group|
              endpoint_prefix_group.each do |endpoint|
                create_file(endpoint.url, endpoint.to_html)
              end
            end
          end
        end
      end

      def convert_to_markdown
        in_root do
          create_file("index.md", meta_presenter.to_markdown) if has_meta_service?
        end

        service_presenters.each do |service_presenter|
          inside_service_presenter(service_presenter) do
            create_file("index.md", service_presenter.to_markdown)

            service_presenter.endpoints.each do |endpoint_prefix_group|
              endpoint_prefix_group.each do |endpoint|
                create_file(endpoint.url('.md'), endpoint.to_markdown)
              end
            end
          end
        end
      end

      def inside_service_presenter(service, &block)
        if has_meta_service?
          inside(service.slug_name, {:verbose => true}, &block)
        else
          in_root(&block)
        end
      end

      def output_path
        @output_path ||=
          if options[:output]
            File.expand_path(options[:output])
          else
            File.expand_path("../#{options[:format]}", origin_path)
          end
      end

      def template_path
        @template_path ||=
          if options[:templates]
            File.expand_path(options[:templates])
          else
            File.expand_path("../templates", origin_path)
          end
      end

      def has_valid_origin?
        origin.directory?
      end

      def has_valid_destination?
        !destination.exist? || destination.directory?
      end

      def has_meta_service?
        !meta_service.empty?
      end

      def service_presenters
        @service_presenters ||= services.map do |service|
          Fdoc::ServicePresenter.new(service, html_options)
        end
      end

      def html_options
        {
          :static_html => true,
          :url_base_path => options[:url_base_path],
          :template_directory => template_path,
          :html_directory => destination_root
        }
      end
    end

    private

    def services
      @services ||=
        if has_meta_service?
          meta_service.services
        else
          [Fdoc::Service.new(origin_path)]
        end
    end

    def meta_presenter
      @meta_presenter ||= Fdoc::MetaServicePresenter.new(
        meta_service,
        html_options
      )
    end

    def meta_service
      @meta_service ||= Fdoc::MetaService.new(origin_path)
    end

    def origin
      Pathname.new(origin_path)
    end

    def destination
      Pathname.new(destination_root)
    end
  end
end
