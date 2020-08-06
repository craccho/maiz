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

  set(:requires) do |key|
    condition do
      case key
      when :access_token
        access_token = @my_env[:session][:access_token]
        if access_token
          @my_env[:access_token] = access_token
        else
          @my_env[:session][:return_to] = request.path_info
          redirect '/oauth/request_user_auth'
        end
      end
    end
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

  get '/', requires: :access_token do
    uri = 'https://api.zaim.net/v2/home/user/verify'
    result = Zaim::OauthConsumer::Operation::CallApi.call(uri: uri, method: :get, **@my_env)
    if result.success?
      result[:response].body
    end
  end

  get '/oauth/request_user_auth' do
    result = Zaim::OauthConsumer::Operation::RequestUserAuth.call(**@my_env)
    if result.success?
      redirect result[:user_auth_url]
    else
      result
    end
  end

  get '/oauth/build_access_token' do
    result = Zaim::OauthConsumer::Operation::BuildAccessToken.call(**@my_env)
    if result.success?
      redirect @my_env[:session][:return_to] || '/'
    else
      Rack::Utils.escape_html(pp result.to_hash)
    end
  end

  require File.join(root, '/config/initializers/autoloader.rb')
  run! if app_file == $PROGRAM_NAME || $PROGRAM_NAME =~ /ruby-prof$/
end
