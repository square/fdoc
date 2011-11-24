class Fdoc::Node

  attr_reader :raw

  def self.key_method_map(*args)
    @key_method_map ||= {}
    return @key_method_map if args.empty?
    map = args[0]
    map.each do |key, method_name|
      define_method method_name do
        raw[key]
      end
    end
    @key_method_map = @key_method_map.merge map
  end

  def self.key_child_map(*args)
    @key_child_map ||= {}
    return @key_child_map if args.empty?
    map = args[0]
    map.each do |key, child_arr|
      method_name, _ = child_arr
      attr_accessor method_name
    end
    @key_child_map.merge! map
  end

  key_method_map({
    "Deprecated" => :deprecated?
  })

  def initialize(data)
    @raw = data || {}
    assert_required_keys

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
      if attribute.kind_of? Fdoc::Node
        hash[key] = attribute.as_hash
      elsif attribute
        hash[key] = attribute
      end
    end
    self.class.key_child_map.each do |key, child_arr|
      method_name, child_class = child_arr
      if attribute = send(method_name)
        hash[key] = attribute.map { |child| child.as_hash }
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
