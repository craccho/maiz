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
    access_token = session[:access_token]
    unless access_token
      redirect '/oauth/request'
      break
    end

    uri = 'https://api.zaim.net/v2/home/user/verify'

    result = Zaim::OauthConsumer::Operation::CallApi.(uri: uri, method: :get, access_token: access_token)
    if result.success?
      result[:response].body
    end
  end

  get '/oauth/request' do
    result = Zaim::OauthConsumer::Operation::Request.(session: session)
    if result.success?
      redirect result[:redirect_url]
    else
      result
    end
  end

  get '/oauth/callback' do
    result = Zaim::OauthConsumer::Operation::Callback.(params: params, session: session)
    if result.success?
      redirect '/'
    else
      result
    end
  end

  require File.join(root, '/config/initializers/autoloader.rb')
  run! if app_file == $PROGRAM_NAME
end
