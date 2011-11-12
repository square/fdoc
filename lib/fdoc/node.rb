class Fdoc::Node

  attr_reader :raw

  def initialize(data)
    @raw = data
    assert_required_keys
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
  
  def deprecated?
    @raw["Deprecated"]
  end
end