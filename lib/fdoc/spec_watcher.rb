require 'json'

module Fdoc
  module SpecWatcher
    VERBS = [:get, :post, :put, :delete]

    VERBS.each do |verb|
      define_method(verb) do |*params|
        action, request_params = params

        request_params = if request_params.kind_of?(Hash)
          request_params
        else
          begin
            JSON.parse(request_params)
          rescue
            {}
          end
        end

        result = super(*params)

        path = if respond_to?(:example) # Rspec 2
          example.metadata[:fdoc]
        else # Rspec 1.3.2
          opts = {}
          __send__(:example_group_hierarchy).each do |example|
            opts.merge!(example.options)
          end
          opts.merge!(options)
          opts[:fdoc]
        end

        real_response = nil
        if defined? response
          # we are on rails
          real_response = response
        else
          # we are on sinatra
          real_response = last_response
        end

        if path
          response_params = begin
            JSON.parse(real_response.body)
          rescue
            {}
          end
          path_params = request.path_parameters.reject { |param| [:action, :controller].include? param }
          successful = Fdoc.decide_success(response_params, real_response.status)
          Service.verify!(verb, path, request_params, response_params, path_params,
            real_response.status, successful)
        end

        result
      end
    end
  end
end
