$:.unshift(File.dirname(__FILE__))

module Fdoc
  DEFAULT_SERVICE_PATH = "docs/fdoc"

  def self.scaffold_mode?
    ENV['FDOC_SCAFFOLD']
  end

  def self.service_path=(service_path)
    @service_path = service_path
  end

  def self.service_path
    @service_path || DEFAULT_SERVICE_PATH
  end

  def self.decide_success_with(&block)
    @success_block = block
  end

  def self.decide_success(*args)
    if @success_block
      @success_block.call(*args)
    else
      true
    end
  end

  class ValidationError < StandardError; end
  class UndocumentedResponseCode < ValidationError; end
end

require 'fdoc/service'
require 'fdoc/meta_service'
require 'fdoc/endpoint'
require 'fdoc/endpoint_scaffold'
require 'fdoc/presenters/html_presenter'
require 'fdoc/presenters/service_presenter'
require 'fdoc/presenters/meta_service_presenter'
require 'fdoc/presenters/endpoint_presenter'
require 'fdoc/presenters/schema_presenter'
require 'fdoc/presenters/response_code_presenter'
