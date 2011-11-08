require 'yaml'

class ResourceChecklist
  def initialize(fdocpath)
    @fdoc = YAML.load_file(fdocpath)
    
    @methods = {}
    @fdoc["Methods"].each { |method, details|
      @methods[method.to_sym] = MethodChecklist.new(method, details)
    }
  end
  
  def controller
    @fdoc['Controller']
  end
  
  def method_checklist_for(methodname)
    @methods[methodname].dup
  end
end
