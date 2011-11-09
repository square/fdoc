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

class Fdoc::MethodChecklist  
  attr_reader :name, :details, :required_params, :optional_params_unused
  
  def initialize(name, details)
    @name, @details = name, details
    
     
    params = details["Parameters"]
    params.each { |param_name, details|
      unless details.has_key? "Required"
        raise "Need to specify if '#{name}.#{param_name}' is required or not."
      end
    }
    
    @required_params = params.select_hash{ |param_name, details| details["Required"] == true }.with_indifferent_access
    @optional_params_unused = params.select_hash{ |param_name, details| details["Required"] == false }.with_indifferent_access
    @optional_params_used = {}.with_indifferent_access
  end
  
  # pass in a hash of parameters that a test sends
  def use(params, from_info=nil)
    params = params.with_indifferent_access
    # make sure that every required parameter is included
    @required_params.each {|param_name, details|
      unless params.has_key? param_name
        raise "Missing param: #{param_name}"
      end
      params.delete param_name
    }
    
    params.each { |param_name, value|
      if @optional_params_used.has_key? param_name
        next # already used, just continue
      elsif @optional_params_unused.has_key? param_name
        # first use: move the parameter from unused to used
        @optional_params_used[param_name] = @optional_params_unused[param_name]
        @optional_params_unused.delete param_name
      else
        raise "Detected undocumented parameter: #{param_name}"
      end
    }
  end
end
