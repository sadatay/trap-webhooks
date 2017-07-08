

require 'sinatra'
require 'require_all'
require_rel 'routes'

module TrapWebhooks
  class App < Sinatra::Application

    # route definitions
    use TrapWebhooks::Routes::Travis

    get '/' do
      status 200
      "[TRAP-WEBHOOKS:BASE] Route Active!"
    end
  end
end

