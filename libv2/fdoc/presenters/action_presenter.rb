module Fdoc
  class ActionPresenter < HTMLPresenter
    def initialize(action, resource_href, base_path, options = {})
      super action, base_path, options
      @resource_href = resource_href
    end
    
    def action
      presented
    end
    
    def name_as_html
      "<span class=\"verb\">#{action.verb.strip}</span> " +
      "<span class=\"base-path\">#{@resource_href.strip}</span>/<span class=\"name\">#{action.name.strip}</span>"
    end

    def html_id
      action.name
    end

    def request_parameters
      action.request_parameters
    end
    
    def required_request_parameters
      (request_parameters["properties"] || []).select { |key, value| value["required"] }
    end
  
    def optional_request_parameters
      (request_parameters["properties"] || []).select { |key, value| not value["required"] }
    end
  
    def response_parameters
      action.response_parameters
    end
  
    def successful_response_codes
      action.response_codes.select { |value| value["successful"] }
    end
  
    def failure_response_codes
      action.response_codes.select { |value| not value["successful"] }
    end
  end
end
