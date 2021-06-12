module Zaim::Operation
  class WithAccessToken < Trailblazer::Operation  # input: %i[uri method oauth_consumer access_token], output: %i[req response]
    step :extract_access_token,             input: %i[session],                      output: %i[access_token]
    step :execute_action # input: %i[action] at least

    def extract_access_token(ctx, session:, **)
      session.includes?(:access_token) && ctx[:access_token] = session[:access_token]
    end

    def execute_action(ctx, action:, **)
      action.call(ctx).success?
    end

  end
end
