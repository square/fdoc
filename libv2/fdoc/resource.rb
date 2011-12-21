module Fdoc
  class Resource
    attr_reader :actions
    
    def initialize(resource_hash)
      @resource = resource_hash
    end

    def self.build_from_file(filename)
      return new YAML.load_file(filename)
    end

    def write_to_file(filename)
    end

    
    def action_for(verb, action_name, options = {:scaffold => false})
      action_hash = @resource["actions"].find { |a| a["verb"] == verb and a["name"] == action_name }
      if action_hash
        return Action.new(action_hash)
      elsif options[:scaffold]
        (@resource["actions"] ||=[]) << action_hash = {
          "name" => action_name,
          "verb" => verb,
          "description" => "???"
        }
        
        action["name"] = action
        action["verb"] = verb
        action["description"] = "???"
        
        return Action.new(action)
      end
    end

    def actions
      @resource["actions"]
    end
    
    def controller
      @resource["controller"]
    end
    
    def scaffold?
      @resource["scaffold"]
    end
    
    def name
      @resource["resourceName"]
    end
  end
end