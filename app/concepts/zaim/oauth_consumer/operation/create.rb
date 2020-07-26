module Zaim::OauthConsumer
  module Operation
    class Create < Trailblazer::Operation
      step :oauth_consumer

      def oauth_consumer(ctx, **)
        ctx[:oauth_consumer] = OAuth::Consumer.new(
          CONSUMER_ID, CONSUMER_SECRET,
          site: PROVIDER_BASE,
          request_token_path: REQUEST_TOKEN_PATH,
          authorize_url: AUTH_URL,
          access_token_path: ACCESS_TOKEN_PATH,
        )
      end
    end
  end
end
