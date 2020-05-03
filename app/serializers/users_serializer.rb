class UsersSerializer
  def initialize(opts)
    @page = opts[:page] || 1
  end

  def all
    response_body['users'].map do |user|
      UserSerializer.new(user, true)
    end
  end

  def response_body
    @response_body ||= JSON.parse(Response.response(url, :get).body)
  end

  def query_params
    {
      page: @page,
    }.to_query
  end

  def url
    [Api::Constants::USERS, query_params].join('?')
  end
end
