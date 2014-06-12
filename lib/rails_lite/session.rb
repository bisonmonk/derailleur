require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @hash = {}
    req.cookies.each do |cookie|
      if cookie.name == '_rails_lite_app'
        parsed = JSON.parse(cookie.value)
        @hash[parsed.keys.first] = parsed.values.first
      end
    end
  end

  def [](key)
    @hash[key]
  end

  def []=(key, val)
    @hash[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @hash.to_json)
  end
end
