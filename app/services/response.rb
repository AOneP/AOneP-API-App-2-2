class Response
  def initialize(url, method_name, opts)
    @uri = URI.parse(url)
    @method_name = method_name
    @opts = opts
  end

  def self.response(url, method_name = :get, opts = {})
    new(url, method_name, opts).response
  end

  def response
    http.request(send("request_#{@method_name}")).tap do |response|
      fail PageNotFoundError if response.code == '404'
      fail "Unhandled code - #{response.code}" if response.code != '200'
    end
  end

  private

  def request_get
    request = Net::HTTP::Get.new(@uri.request_uri).tap do |request|
      request.body = "{}"
      request.set_content_type('application/json')
    end
  end

  def request_post
    @request_post ||= Net::HTTP::Post.new(@uri.request_uri).tap do |request|
      request.body = @opts[:payload].to_json
      request.set_content_type('application/json')
    end
  end

  def http
    Net::HTTP.new(@uri.host, @uri.port)
  end
end
