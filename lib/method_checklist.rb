require 'yaml'

# filter a hash and get a hash back
class Hash
  def select_hash(&block)
    result = {}
    self.each {|key, value|
      if block.call(key, value)
        result[key] = value
      end
    }
    result
  end
end

class MethodChecklist
  attr_reader :name, :details, :required_params, :optional_params_unused
  
  def initialize(name, details)
    @name, @details = name, details
    
    # TODO: throw an error if a parameter does not have a Required attrib
    @required_params = details["Parameters"].select_hash{ |param_name, details| details["Required"] == true }
    @optional_params_unused = details["Parameters"].select_hash{ |param_name, details| details["Required"] == false }
    @optional_params_used = {}
  end
  
  # pass in a hash of parameters that a test sends
  def use(params, from_info=nil)
    # make sure that every required parameter is included
    @required_params.each {|param_name, details|
      unless params.has_key? param_name
        # TODO: throw an error because a required param is missing
      end
    }
    
    params.each { |param_name, value|
      if @optional_params_used.has_key? param_name
        continue # already used, just continue
      elsif @optional_params_unused.has_key? param_name
        # first use: move the parameter from unused to used
        @optional_params_used[param_name] = @optional_params_unused[param_name]
        @optional_params_unused.delete param_name
      else
        # TODO: throw an error because an undocumented parameter was used
      end
    }
  end
end
