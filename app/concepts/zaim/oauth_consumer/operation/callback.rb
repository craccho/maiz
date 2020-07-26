module Zaim::OauthConsumer
  module Operation
    class Callback < Trailblazer::Operation
      step Subprocess(Create)
      step :callback

      def callback(ctx, params:, session:, **)
        oauth_consumer = ctx[:oauth_consumer]
        hash = { oauth_token: session[:token], oauth_token_secret: session[:token_secret] }
        request_token = OAuth::RequestToken.from_hash(oauth_consumer, hash)
        access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
        session[:access_token] = access_token
      end
    end
  end
end
