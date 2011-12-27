module Fdoc
  class HTMLPresenter
    attr_reader :presented, :options
    
    def initialize(presented, base_path, options = {})
      @presented = presented
      @base_path = base_path
      @options = options
    end
    
    def index_path
      path = @base_path
      path = "/" + path unless options[:html]
      path
    end

    def css_path
      path = "#{@base_path}/main.css"
      path = "/" + path unless options[:html]
      path
    end
    
    def get_binding
      binding
    end
  
    def as_html
    end
  end
end