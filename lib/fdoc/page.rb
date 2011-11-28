module Fdoc
  class Page
    def get_binding
      binding
    end

    def index_path
      path = @base_path
      path = "/" + path unless @options[:html]
      path
    end

    def css_path
      path = "#{@base_path}/main.css"
      path = "/" + path unless @options[:html]
      path
    end
  end

  class DirectoryPage < Page
    def initialize(resources, base_path, options = {})
      @resources = resources
      @base_path = base_path
      @options = options
    end
  
    def resource_path(resource)
      path = "#{@base_path}/#{resource.name}"
      if @options[:html]
        path += ".html"
      else
        path = "/" + path
      end
      path
    end    
  end  

  class ResourcePage < Page
    def initialize(resource, base_path, options = {})
      @resource = resource
      @base_path = base_path
      @options = options
    end
  end
end
