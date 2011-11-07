require 'yaml'

class ResourceChecklist
  attr_accessor :fdoc

  def initialize(fdocpath)
    @fdoc = YAML.load_file(fdocpath)
    
    @methods = {}
    @fdoc["Methods"].each { |method, details|
      @methods[method] = MethodChecklist.new(method, details)
    }
  end
end