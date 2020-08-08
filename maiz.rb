require 'pry'
require 'byebug'
require 'sinatra/base'
require 'sinatra/reloader'

class Maiz < Sinatra::Base
  require File.join(root, '/config/initializers/autoloader.rb')

  use OmniAuth::Builder do
    provider :zaim, ENV['ZAIM_CONSUMER_ID'], ENV['ZAIM_CONSUMER_SECRET']
  end

  set :environment, :development
  set :sessions, true
  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def current_user
      !session[:uid].nil?
    end
  end

  get '/auth/zaim/callback' do
    session[:uid] = env['omniauth.auth']['uid']
    session[:access_token] = env['omniauth.auth']['extra']['access_token']
    session[:info] = env['omniauth.auth']['info']

    redirect back
  end

  before do
    pass if request.path_info =~ /^\/auth\//
    redirect to('/auth/zaim') unless current_user
  end

  get '/' do
    result = session[:access_token].get('/v2/home/user/verify')
    pp session[:auth].to_h
    result.body
  end

  get '/auth/logout' do
    session[:uid] = nil
    session[:access_token] = nil
    session[:info] = nil

    redirect to('/')
  end

  run! if app_file == $PROGRAM_NAME || $PROGRAM_NAME =~ /ruby-prof$/
end
