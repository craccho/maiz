# typed: false
# frozen_string_literal: true

require 'bundler'
require 'pry'
require 'byebug'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/basic_auth'

# maiz
class Maiz < Sinatra::Base
  require File.join(root, '/config/initializers/autoloader.rb')

  register Sinatra::BasicAuth

  authorize 'Test' do |username, password|
    username == 'foo' && password == 'bar'
  end

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
    pass unless request.path_info =~ %r{^/$}
    redirect to('/auth/zaim') unless current_user
  end

  get '/' do
    result = session[:access_token].get('/v2/home/user/verify')
    pp session[:auth].to_h
    result.body
  end

  protect 'Test' do
    get '/test' do
      'me'
    end
  end

  get '/auth/logout' do
    session[:uid] = nil
    session[:access_token] = nil
    session[:info] = nil

    redirect to('/')
  end

  run! if app_file == $PROGRAM_NAME || $PROGRAM_NAME =~ /ruby-prof$/
end
