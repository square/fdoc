module Fdoc
  class ParameterPresenter < HTMLPresenter

    def initialize(name, properties, base_path, options = {})
      super nil, base_path, options
      @name = name
      @properties = properties
    end
    
    def as_html
      ""
    end
  end
end