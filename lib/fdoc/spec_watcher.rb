module Fdoc
  module SpecWatcher
    VERBS = [:get, :post, :put, :delete]

    VERBS.each do |verb|
      define_method(verb) do |*params|
        action, request_params = params
        request_params ||= {}
        result = super(*params)

        all_opts = if respond_to?(:example) # Rspec 2
          example.metadata
        else # Rspec 1.3.2
          opts = {}
          __send__(:example_group_hierarchy).each do |example|
            opts.merge!(example.options)
          end
          opts.merge!(options)
          opts
        end

        path    = all_opts[:fdoc]
        success = all_opts.has_key?(:success) ? all_opts[:success] : true

        if path
          response_params = begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            {}
          end
          verify!(verb, path, request_params, response_params, response.status, success)
        end

        result
      end
    end

    private

    def verify!(verb, path, request_params, response_params, response_status, success)
      service = Service.new(Fdoc.service_path)
      endpoint = service.open(verb, path)
      endpoint.consume_request(request_params)
      endpoint.consume_response(response_params, response_status)
      endpoint.persist! if endpoint.respond_to?(:persist!)
    end
  end
end
