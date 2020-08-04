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
  set :environment, :development
  set :sessions, true
  configure :development do
    register Sinatra::Reloader
  end

  before do
    @my_env = {
      oauth_consumer: self.class.oauth_consumer,
      session: session,
      params: params,
    }
  end

  def self.oauth_consumer
    result = Zaim::OauthConsumer::Operation::Create.call
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

    result = Zaim::OauthConsumer::Operation::CallApi.call(uri: uri, method: :get, access_token: access_token, **@my_env)
    if result.success?
      result[:response].body
    end
  end

  get '/oauth/request' do
    result = Zaim::OauthConsumer::Operation::Request.call(**@my_env)
    if result.success?
      redirect result[:redirect_url]
    else
      result
    end
  end

  get '/oauth/callback' do
    result = Zaim::OauthConsumer::Operation::Callback.call(**@my_env)
    if result.success?
      redirect '/'
    else
      Rack::Utils.escape_html(pp result.to_hash)
    end
  end

  require File.join(root, '/config/initializers/autoloader.rb')
  run! if app_file == $PROGRAM_NAME || $PROGRAM_NAME =~ /ruby-prof$/
end
