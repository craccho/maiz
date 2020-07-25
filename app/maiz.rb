#!/usr/bin/ruby

require 'byebug'
require 'oauth'
require 'yaml'
require 'net/http'
require 'sinatra/base'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

CONSUMER_ID = ENV['ZAIM_CONSUMER_ID']
CONSUMER_SECRET = ENV['ZAIM_CONSUMER_SECRET']
PROVIDER_BASE = 'https://api.zaim.net'.freeze
REQUEST_TOKEN_PATH = '/v2/auth/request'.freeze
AUTH_URL = 'https://auth.zaim.net/users/auth'.freeze
ACCESS_TOKEN_PATH = '/v2/auth/access'.freeze
MY_URL = 'http://localhost:4567/'.freeze
CALLBACK_URL = "#{MY_URL}oauth/callback".freeze

class Maiz < Sinatra::Base
  set :sessions, true

  def get_oauth_consumer
    OAuth::Consumer.new(
      CONSUMER_ID, CONSUMER_SECRET,
      site: PROVIDER_BASE,
      request_token_path: REQUEST_TOKEN_PATH,
      authorize_url: AUTH_URL,
      access_token_path: ACCESS_TOKEN_PATH,
    )
  end

  get '/oauth/logout' do
    session[:access_token] = nil
    redirect '/'
  end

  get '/' do
    oauth_consumer = get_oauth_consumer

    access_token = session[:access_token]
    unless access_token
      redirect '/oauth/request'
      break
    end
    oauth_params = { consumer: oauth_consumer, token: access_token }
    hydra = Typhoeus::Hydra.new
    uri = 'https://api.zaim.net/v2/home/user/verify'
    options = { method: :get }
    req = Typhoeus::Request.new(uri, options)
    oauth_helper = OAuth::Client::Helper.new(req, oauth_params.merge(request_uri: uri))
    req.options[:headers].merge!({ 'Authorization' => oauth_helper.header })
    hydra.queue(req)
    hydra.run
    req.response.body
  end

  get '/oauth/request' do
    oauth_consumer = get_oauth_consumer
    request_token = oauth_consumer.get_request_token(oauth_callback: CALLBACK_URL)
    session[:token] = request_token.token
    session[:token_secret] = request_token.secret
    redirect request_token.authorize_url(oauth_callback: CALLBACK_URL)
  end

  get '/oauth/callback' do
    oauth_consumer = get_oauth_consumer
    hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret] }
    request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
    access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
    session[:access_token] = access_token
    redirect '/'
  end

  run! if app_file == $PROGRAM_NAME
end
