require 'yaml'

# MetaServices are collections of services
class Fdoc::MetaService
  attr_reader :meta_service_dir

  def initialize(meta_service_dir)
    @meta_service_dir = File.expand_path(meta_service_dir)

    service_path = Dir["#{meta_service_dir}/*.fdoc.meta"].first
    @schema = if service_path
      YAML.load_file(service_path)
    else
      {}
    end
  end

  def empty?
    @schema.empty?
  end

  def services
    @schema['services'].map do |path|
      service_path = if path.start_with?('/') || path.start_with?('~')
        path
      else
        File.join(meta_service_dir, path)
      end
      serv = Fdoc::Service.new(service_path)
      serv.meta_service = self
      serv
    end
  end

  def name
    @schema['name']
  end

  def description
    @schema['description']
  end

  def discussion
    @schema['discussion']
  end
end
