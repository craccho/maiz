require 'pry'
require 'byebug'
require 'oauth'
require 'yaml'
require 'net/http'
require 'sinatra/base'
require 'sinatra/reloader'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

class Maiz < Sinatra::Base
  set :sessions, true
  configure :development do
    register Sinatra::Reloader
  end

  def oauth_consumer
    result = Zaim::OauthConsumer::Operation::Create.()
    result.success? ? result[:oauth_consumer] : nil
  end

  get '/oauth/logout' do
    session[:access_token] = nil
    redirect '/'
  end

  get '/' do
    oauth_consumer = self.oauth_consumer

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
    oauth_consumer = self.oauth_consumer
    request_token = oauth_consumer.get_request_token(oauth_callback: Zaim::OauthConsumer::CALLBACK_URL)
    session[:token] = request_token.token
    session[:token_secret] = request_token.secret
    redirect request_token.authorize_url(oauth_callback: Zaim::OauthConsumer::CALLBACK_URL)
  end

  get '/oauth/callback' do
    oauth_consumer = self.oauth_consumer
    hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret] }
    request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
    access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
    session[:access_token] = access_token
    redirect '/'
  end

  require File.join(root, '/config/initializers/autoloader.rb')
  run! if app_file == $PROGRAM_NAME
end
