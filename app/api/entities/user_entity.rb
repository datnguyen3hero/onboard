module Entities
  class UserEntity < Grape::Entity
    expose :id, :name, :email, :timezone, :token
  end
end
