module Fdoc
  class Resource
    def initialize(resource_hash)
      @resource = resource_hash
    end

    def self.build_from_file(filename)
      return new YAML.load_file(filename)
    end

    def write_to_file(filename)
      File.open(filename, "w") { |f| f.write(YAML.dump(@resource)) }
    end
    
    def action_for(verb, action_name, options = {:scaffold => false})
      if action = actions.map { |hash| Fdoc::Action.new hash }.find { |a| a.verb == verb and a.name == action_name }
        if (action.scaffold? || false) == options[:scaffold] 
          return action
        elsif action.scaffold? and not options[:scaffold]
          return nil
        elsif options[:scaffold] and not action.scaffold?
          raise Fdoc::ActionAlreadyExistsError, "Action for #{verb} #{action_name} already exists, can't scaffold"
        end
      elsif options[:scaffold]
        actions << {
          "name" => action_name,
          "verb" => verb,
          "description" => "???",
          "scaffold" => true
        }
        
        Fdoc::Action.new actions.last
      end
    end

    # properties. should probably be generated.

    def actions
      @resource["actions"] ||= []
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