class UserSerializer
  def initialize(response_body, parsed = false)
    @parsed_body =  if parsed
                      response_body
                    else
                      JSON.parse(response_body)
                    end
    @errors = (@parsed_body['errors'] || [])
  end

  def self.find(id)
    response_body = JSON.parse(Response.response("http://localhost:3000/api/users/#{id}").body)
    new(response_body, true)
  end

  def id
    @parsed_body['id']
  end

  def name
    @parsed_body['name']
  end

  def zawod
    @parsed_body['zawod']
  end

  def errors
    @parsed_body['errors']
  end
end
