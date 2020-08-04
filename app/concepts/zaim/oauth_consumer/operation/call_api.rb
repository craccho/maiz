require_relative 'create'
module Zaim::OauthConsumer
  module Operation
    class CallApi < Trailblazer::Operation  # input: %i[uri method oauth_consumer access_token], output: %i[req response]
      step :build_request,                    input: %i[uri method],                      output: %i[req]
      step :build_oauth_params,               input: %i[oauth_consumer access_token uri], output: %i[oauth_params]
      step :add_authorization_header_to_req,  input: %i[oauth_params req],                output: %i[req]
      step :do_request,                       input: %i[req],                             output: %i[req, response]

      def build_request(ctx, uri:, method:, **)
        ctx[:req] = Typhoeus::Request.new(uri, {method: method})
      end

      def build_oauth_params(ctx, oauth_consumer:, access_token:, uri:, **)
        ctx[:oauth_params] = {
          consumer: oauth_consumer,
          token: access_token,
          request_uri: uri
        }
      end

      def add_authorization_header_to_req(_ctx, oauth_params:, req:, **)
        oauth_helper = OAuth::Client::Helper.new(req, oauth_params)
        req.options[:headers].merge!({ 'Authorization' => oauth_helper.header })
      end

      def do_request(ctx, req:, **)
        hydra = Typhoeus::Hydra.new
        hydra.queue(req)
        hydra.run
        ctx[:response] = req.response
      end
    end
  end
end
