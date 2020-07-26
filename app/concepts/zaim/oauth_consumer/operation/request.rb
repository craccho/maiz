require './app/concepts/zaim/oauth_consumer/operation/create'
module Zaim::OauthConsumer
  module Operation
    class Request < Trailblazer::Operation
      step Subprocess(Create)
      step :request
      step :save_to_session
      step :url_to_redirect

      def request(ctx, **)
        oauth_consumer = ctx[:oauth_consumer]
        ctx[:request_token] = oauth_consumer.get_request_token(oauth_callback: CALLBACK_URL)
      end

      def save_to_session(ctx, session:, **)
        session[:token] = ctx[:request_token].token
        session[:token_secret] = ctx[:request_token].secret
      end

      def url_to_redirect(ctx, **)
        ctx[:redirect_url] = ctx[:request_token].authorize_url(oauth_callback: CALLBACK_URL)
      end
    end
  end
end
