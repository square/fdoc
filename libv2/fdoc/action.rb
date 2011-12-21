module Fdoc
  class Action
    def initialize(action_hash)
      @action = action_hash
    end

    def consume_request(params, headers = {})
      parameters_schema = @action["requestParameters"].dup
      
      
      
      JSON::Validator.validate(parameters_schema, headers)
      # validates the parameters against requestParameters
      # validates the headers against requestHeaders

      # in order to error on unknown keys, it should recursively dive down 
      # and set additionalProperties => false <<<< important
    
      # should be relatively simple, but may need to dive down and replace $refs with
      # the appropriate types from its resource (parent)
    end

    def consume_response(params, rails_response, successful = true)
      # validates the existence of the HTTP respose/succesful combo
      # validates the parameters against the requestParameters schema
    end

    def scaffold_request(params, headers = {})
      # attempts to fill out an fdoc based on the request
    end

    def scaffold_response(params, rails_response, successful = true)
      # attempts to fill out an fdoc based on the response
    end
  end
end