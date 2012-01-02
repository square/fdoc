# A resource represents a particular model, or entity in the domain.
# It contains many actions and an instance is responsible for finding its own actions
class Fdoc::Resource
  def initialize(resource_hash)
    @resource = resource_hash
    validate!
  end

  def self.build_from_file(filename)
    return self.new(YAML.load_file(filename))
  end

  def write_to_file(path = "docs/fdoc")
    filename = File.join(path, "#{name}.fdoc")
    File.open(filename, "w") { |io| YAML.dump(@resource, io) }
  end

  def action_for(verb, action_name, options = {:scaffold => false})
    action = actions.map {|a| Fdoc::Action.new a }.find { |a| a.verb == verb && a.name == action_name }
    if action
      if options[:scaffold] && !action.scaffold?
        raise Fdoc::ActionAlreadyExistsError,
          "Action for #{verb} #{action_name} already exists, can't scaffold"
      end
      action
    elsif options[:scaffold]
      actions << {
        "name" => action_name,
        "verb" => verb,
        "description" => "???",
        "scaffold" => true
      }
      Fdoc::Action.new actions.last
    end
  end

  # properties. should probably be generated.

  def actions
    @resource["actions"] ||= []
  end

  def controller
    @resource["controller"]
  end

  def scaffold?
    @resource["scaffold"]
  end

  def name
    @resource["resourceName"]
  end

  def description
    @resource["description"]
  end

  def base_path
    @resource["basePath"]
  end

  private
  def validate!
    JSON::Validator.validate!(Fdoc.schema, @resource)
  end
end
