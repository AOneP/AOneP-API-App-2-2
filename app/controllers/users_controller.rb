require 'net/http'
require 'json'

module Api
  module Constants
    USERS = 'http://localhost:3000/api/users'.freeze
  end
end

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
    binding.pry
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

class UsersController < ApplicationController
  def show
    # uri = URI('http://localhost:3000/api/users/1')
    # @users = Net::HTTP.get(uri)
    @user = UserSerializer.find(params[:id])
    # @person = JSON.parse(@users, object_class: OpenStruct)
  end

  def index
    @users = UsersSerializer.new(page: page).all
  end

  def next_page
    return params["page"].to_i += 1
    render :index
  end

  def previous_page
  end

  def page
    params["page"].to_i || 0
  end

  def new
    @response = {}
  end

  def create
    payload = {user:{name: user_params["name"], zawod: user_params["zawod"]}}
    @response = JSON.parse(Response.response('http://localhost:3000/api/users', :post, payload: payload).body)
    if @response["errors"].present?
      render :new
    else
      redirect_to users_path
    end
  end

  def user_params
    params.permit(:name, :zawod)
  end
end


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
