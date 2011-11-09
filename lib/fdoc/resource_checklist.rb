class Fdoc::ResourceChecklist
  def self.build_from_file(fdoc_path)
    new YAML.load_file(fdoc_path)
  end
  
  def initialize(data)
    @resource = Fdoc::Resource.new(data)
  end
  
  def controller
    @resource.controller
  end
  
  def method_checklist_for(methodname)
    Fdoc::MethodChecklist.new(@resource.action(methodname.to_s))
  end
end
