=begin

Fdoc::Node is probably the strangest, most confusing class in all of fdoc, but
it bundles together a lot of nicesness for the rest of the project.

The purpose of the class is to simply and standardize mapping objects from
their dictionary representations (which in thise case are YAML/JSON).  Every
node object is created from a dictionary, and every node object's #as_hash
should map this object directly back to its dictionary.

Fdoc::Node is basically an abstract class, it is too simple to have any real
meaning.  Meaningful subclasses can specify their properties and children via
class methods.  In the domain of documentation, Fdoc::DocNode is the meaningful
class from which new classes should inherit.

- required_keys
  For a subclass, setting required_keys will mean that, in order to be a valid
  instance of this subclass, these keys must be specified in the dictionary
  representation

- map_keys_to_methods
  For a subclass, this defines simple accessors for keys in the dictionary representation.
  To read this for a class, use key_method_map

- map_keys_to_children
  Similar to map_keys_to_methods, but instead of providing a simple read/write
  interface to an attribute, these map to new objects, which defines a
  parent-child relationship.
  To read this for a class, use key_child_map

=end

class Fdoc::Node

  attr_reader :raw

  @@key_method_maps = {}
  @@key_child_maps = {}

  def self.map_keys_to_methods(map)
    @@key_method_maps[self.to_s] = map
    map.each do |key, method_name|
      define_method method_name do
        raw[key]
      end

      define_method "#{method_name.to_s.gsub(/\?$/, '')}=".to_sym do |val|
        raw[key] = val
      end
    end
  end

  def self.key_method_map
    @@key_method_maps[self.to_s] ||= {}
    key_method_map = @@key_method_maps[self.to_s]
    if superclass.respond_to? :key_method_map
      return key_method_map.merge superclass.send(:key_method_map)
    end
    key_method_map
  end

  def self.map_keys_to_children(map)
    @@key_child_maps[self.to_s] = map
    map.each do |key, child_arr|
      method_name, _ = child_arr
      attr_accessor method_name
    end
  end

  def self.key_child_map
    @@key_child_maps[self.to_s] ||= {}
    key_child_map = @@key_child_maps[self.to_s]

    if superclass.respond_to? :key_child_map
      return key_child_map.merge superclass.send(:key_child_map)
    end
    key_child_map
  end

  def initialize(data={})
    if partial_data = data[:partial_data]
      @raw = partial_data
    else
      @raw = data
      assert_required_keys
    end

    self.class.key_child_map.each do |key, child_arr|
      method_name, child_class = child_arr
      setter = ("#{method_name}=").to_sym
      send(setter, Array(raw[key]).map{ |child_data| child_class.new(child_data)})
    end
  end


  def as_hash
    hash = {}
    self.class.key_method_map.each do |key, method_name|
      attribute = send(method_name)
      unless attribute.nil?
        hash[key] = attribute
      end
    end

    self.class.key_child_map.each do |key, child_args|
      method_name, child_class = child_args
      child_array = send(method_name)
      unless child_array.empty?
        hash[key] = child_array.map { |child| child.as_hash }
      end
    end
    hash
  end

  def self.required_keys(*args)
    @required_keys ||= []
    return @required_keys if args.empty?
    (@required_keys << args).flatten!
  end

  def assert_required_keys
    self.class.required_keys.each do |key|
      raise Fdoc::MissingAttributeError, "Required key not present: #{key}\n Missing from: #{raw.inspect}" if raw[key] == nil
    end
  end
end
