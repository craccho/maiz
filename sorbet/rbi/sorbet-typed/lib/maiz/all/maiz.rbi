# typed: strong

class Maiz
    extend Sinatra::BasicAuth
    sig { params(provider: Symbol, consumer_id: T.nilable(String), secret: T.nilable(String)).void }
    def self.provider(provider, consumer_id, secret); end
end
