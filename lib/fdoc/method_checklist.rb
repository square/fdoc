class Fdoc::MethodChecklist
  attr_reader :name, :details, :required_params, :optional_params_unused

  def initialize(method)
    @method = method
  end

  # pass in a hash of parameters that a test sends
  def use(params, from_info=nil)
    # make sure that every required parameter is included
    @method.required_parameters.each do |parameter|
      unless params.has_key? parameter.name.to_sym
        raise "Missing required param: #{parameter.name}"
      end
    end

    params.each do |param_name, value|
      raise "Detected undocumented parameter: #{param_name}" unless @method.parameters.map(&:name).include?(param_name.to_s)
    end
    # params.each { |param_name, value|
    #   if @optional_params_used.has_key? param_name
    #     next # already used, just continue
    #   elsif @optional_params_unused.has_key? param_name
    #     # first use: move the parameter from unused to used
    #     @optional_params_used[param_name] = @optional_params_unused[param_name]
    #     @optional_params_unused.delete param_name
    #   else
    #   end
    # }
  end
end
