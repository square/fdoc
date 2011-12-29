module Fdoc
  class ResourcePresenter < HTMLPresenter
    def resource
      presented
    end

    def resource_path
      path = "#{@base_path}/#{resource.name}"
      if options[:html]
        path += ".html"
      else
        path = "/" + path
      end
      path
    end
  end
end
