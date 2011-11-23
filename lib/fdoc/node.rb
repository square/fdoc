class Fdoc::Node

  attr_reader :raw
  
  def self.key_method_map(map)
    @key_method_map ||= {}
    return @key_method_map if map.empty?
    map.each do |key, method_name|
      define_method method_name do
        raw[key]
      end
    end
    @key_method_map = @key_method_map.merge map
  end
  
  key_method_map({
    "Deprecated" => :deprecated?
  })

  def initialize(data)
    @raw = data
    assert_required_keys
  end

  def as_hash
    hash = {}
    self.class.key_method_map.each do |key, method_name|
      attribute = send(method_name)
      if attribute.kind_of? Fdoc::Node
        hash[key] = attribute.as_hash
      else
        hash[key] = attribute
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