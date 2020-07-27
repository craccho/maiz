module Zaim::OauthConsumer
  module Operation
    class Callback < Trailblazer::Operation
      step Subprocess(Create)
      step :extract_request_token
      step :get_access_token
      step :store_access_token_to_session

      def extract_request_token(ctx, session:, **)
        oauth_consumer = ctx[:oauth_consumer]
        hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret] }
        ctx[:request_token] = OAuth::RequestToken.from_hash(oauth_consumer, hash)
      end

      def get_access_token(ctx, params:, **)
        ctx[:access_token] = ctx[:request_token].get_access_token(oauth_verifier: params[:oauth_verifier])
      end

      def store_access_token_to_session(ctx, session:, **)
        session[:access_token] = ctx[:access_token]
      end
    end
  end
end
