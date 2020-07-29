require_relative 'create'
module Zaim::OauthConsumer
  module Operation
    class Request < Trailblazer::Operation
      step Subprocess(Create)
      step :get_request_token,             input: [:oauth_consumer],          output: [:request_token]
      step :save_request_token_to_session, input: [:session, :request_token], output: []
      step :url_to_redirect,               input: [:request_token],           output: [:redirect_url]

      def get_request_token(ctx, oauth_consumer:, **)
        ctx[:request_token] = oauth_consumer.get_request_token(oauth_callback: CALLBACK_URL)
      end

      def save_request_token_to_session(ctx, session:, request_token:, **)
        session[:token] = request_token.token
        session[:token_secret] = request_token.secret
      end

      def url_to_redirect(ctx, request_token:, **)
        ctx[:redirect_url] = request_token.authorize_url(oauth_callback: CALLBACK_URL)
      end
    end
  end
end
