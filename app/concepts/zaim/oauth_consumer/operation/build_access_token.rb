module Zaim::OauthConsumer
  module Operation
    class MyHandler
      def self.call(exception, (ctx), *)
        ctx[:exception_class] = exception.class
        false
      end
    end

    class BuildAccessToken < Trailblazer::Operation
      step :extract_request_token, input: %i[oauth_consumer session], output: %i[request_token]
      step Rescue( Exception, handler: MyHandler ) {
        step :get_access_token, input: %i[request_token params], output: %i[access_token]
      }
      step :store_access_token_to_session, input: %i[access_token session], output: %i[]

      def extract_request_token(ctx, oauth_consumer:, session:, **)
        hash = {
          oauth_token: session[:token],
          oauth_token_secret: session[:token_secret]
        }
        ctx[:request_token] = OAuth::RequestToken.from_hash(oauth_consumer, hash)
      end

      def get_access_token(ctx, request_token:, params:, **)
        ctx[:access_token] = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      end

      def store_access_token_to_session(_ctx, access_token:, session:, **)
        session[:access_token] = access_token
      end
    end
  end
end
