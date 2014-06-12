require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  attr_accessor :permitted
  
  def initialize(req, route_params = {})
    @permitted = []
    @params = {}
    if !req.query_string.nil?
      @params = parse_www_encoded_form(req.query_string)
    elsif !req.body.nil?
      @params.merge!(parse_www_encoded_form(req.body))
    elsif !route_params.nil?
      @params.merge!(route_params)
    end
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted += keys
  end

  def require(key)
    if !@params.keys.include?(key)
      raise AttributeNotFoundError.new
    end
  end
  
  def permitted?(key) 
    @permitted.include?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;
  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    keys = URI.decode_www_form(www_encoded_form)
        
    hashes = []
    key = nil
    
    keys.each do |parts|
      parts[0...-1].each do |part|
        part = part.gsub(/\[/, ' ')
        part = part.gsub(/]/, '')
        part = part.split(' ')

        key = part
      end
      hashes << key.reverse.inject(parts[-1]) { |a, n| { n => a } }
    end
    result = hashes.first
    1.upto(hashes.count - 1) do |i|
      result = result.deep_merge(hashes[i])
    end
    return result
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
  end
end
