# typed: true
module Zaim::OauthConsumer
  module Operation
    class GetConsumer < Trailblazer::Operation
      step :get_oauth_consumer_from_session, input: %i[env], output: %i[oauth_consumer]

      def get_oauth_consumer_from_session(ctx, env:, **)
        if env.include?(:session)
          if env.include?(:oauth_consumer)
            ctx[:oauth_consumer] = env[:session][:oauth_consumer]
          else
            result = Create.call
            if result.success?
              ctx[:oauth_consumer] = result[:oauth_consumer]
              env[:session][:oauth_consumer] = ctx[:oauth_consumer]
            else
              ctx[:error] = "failed to create oauth consumer"
              false
            end
          end
        else
          ctx[:error] = "session is disabled"
        end
      end
    end
  end
end
