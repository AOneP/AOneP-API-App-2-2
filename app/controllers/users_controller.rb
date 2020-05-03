require 'net/http'
require 'json'

module Api
  module Constants
    USERS = 'http://localhost:3000/api/users'.freeze
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
