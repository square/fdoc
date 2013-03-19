require 'json'

module Fdoc
  module SpecWatcher
    VERBS = [:get, :post, :put, :delete]

    VERBS.each do |verb|
      define_method(verb) do |*params|
        action, request_params = params

        super(*params)

        check_response(verb, request_params) if path
      end
    end

    private

    def check_response(verb, request_params)
      successful = Fdoc.decide_success(response_params, real_response.status)
      Service.verify!(verb, path, parsed_request_params(request_params), response_params,
                      real_response.status, successful)
    end

    def parsed_request_params request_params
      if request_params.kind_of?(Hash)
        request_params
      else
        begin
          JSON.parse(request_params)
        rescue
          {}
        end
      end
    end

    def path
      if respond_to?(:example) # Rspec 2
        example.metadata[:fdoc]
      else # Rspec 1.3.2
        opts = {}
        __send__(:example_group_hierarchy).each do |example|
          opts.merge!(example.options)
        end
        opts.merge!(options)
        opts[:fdoc]
      end
    end

    def real_response
      if respond_to? :response
        # we are on rails
        response
      else
        # we are on sinatra
        last_response
      end
    end

    def response_params
      begin
        JSON.parse(real_response.body)
      rescue
        {}
      end
    end

  end
end
