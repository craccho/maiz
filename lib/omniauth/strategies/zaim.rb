require 'omniauth-oauth'
require 'typhoeus'
require 'oauth/request_proxy/typhoeus_request'

module OmniAuth
  module Strategies
    class Zaim < OmniAuth::Strategies::OAuth
      PROVIDER_BASE = 'https://api.zaim.net'.freeze
      REQUEST_TOKEN_PATH = '/v2/auth/request'.freeze
      AUTH_URL = 'https://auth.zaim.net/users/auth'.freeze
      ACCESS_TOKEN_PATH = '/v2/auth/access'.freeze

      option :name, "zaim"
      option :client_options, {
        site: PROVIDER_BASE,
        request_token_path: REQUEST_TOKEN_PATH,
        authorize_url: AUTH_URL,
        access_token_path: ACCESS_TOKEN_PATH,
      }

      uid { raw_info['me']['name'] }

      info do
        puts raw_info
        {
          login: raw_info['me']['login'],
          id: raw_info['me']['id'],
          name: raw_info['me']['name'],
          image_url: raw_info['me']['profile_image_url'],
        }
      end

      extra do
        skip_info? ? {} : { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= JSON.load(access_token.get('/v2/home/user/verify').body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end
