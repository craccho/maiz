require 'dry-types'
require 'dry-struct'

module Types
  include Dry.Types()
end

# User = Dry.Struct(name: Types::String, age: Types::Integer)

class User < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :age,  Types::Strict::Integer
end

User.new(name: 'Bob', age: '35')
