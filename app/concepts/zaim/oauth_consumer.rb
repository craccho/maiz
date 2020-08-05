require 'oauth'
require 'oauth/request_proxy/typhoeus_request'

module Zaim
  module OauthConsumer
    PROVIDER_BASE = 'https://api.zaim.net'.freeze
    REQUEST_TOKEN_PATH = '/v2/auth/request'.freeze
    AUTH_URL = 'https://auth.zaim.net/users/auth'.freeze
    ACCESS_TOKEN_PATH = '/v2/auth/access'.freeze

    CONSUMER_ID = ENV['ZAIM_CONSUMER_ID']
    CONSUMER_SECRET = ENV['ZAIM_CONSUMER_SECRET']
    MY_URL = 'http://localhost:4567/'.freeze
    CALLBACK_URL = "#{MY_URL}oauth/build_access_token".freeze
  end
end
