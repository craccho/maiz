require './app/concepts/zaim/oauth_consumer/operation/create'
module Zaim::OauthConsumer
  module Operation
    class CallApi < Trailblazer::Operation
      step Subprocess(Create)
      step :make_request

      def make_request(ctx, access_token:, uri:, method:, **)
        oauth_params = { consumer: ctx[:oauth_consumer], token: access_token, request_uri: uri}
        hydra = Typhoeus::Hydra.new
        req = Typhoeus::Request.new(uri, {method: method})
        oauth_helper = OAuth::Client::Helper.new(req, oauth_params)
        req.options[:headers].merge!({ 'Authorization' => oauth_helper.header })
        hydra.queue(req)
        hydra.run
        ctx[:response] = req.response
      end
    end
  end
end
