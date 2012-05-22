module Fdoc
  module SpecWatcher
    VERBS = [:get, :post, :put, :delete]

    VERBS.each do |verb|
      define_method(verb) do |action, request_params = {}|
        result = super(action, request_params)

        if path = example.metadata[:fdoc]
          response_params = begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            {}
          end
          response_status = response.status
          verify!(verb, path, request_params, response_params, response_status)
        end

        result
      end
    end

    private

    def verify!(verb, path, request_params, response_params, response_status)
      service = Service.new(Fdoc.service_path)
      endpoint = service.open(verb, path)
      endpoint.consume_request(request_params)
      endpoint.consume_response(response_params, response_status)
      endpoint.persist! if endpoint.respond_to?(:persist!)
    end
  end
end
