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

      define_method method_name.to_s.gsub(/\?$/, '').to_sym do |val|
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
      p method_name
      attr_accessor method_name
      puts defined?("#{method_name}=")
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

  map_keys_to_methods({
    "Deprecated" => :deprecated?
  })

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
