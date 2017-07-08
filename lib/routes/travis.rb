require 'sinatra/base'
require 'json'
require 'faraday'
require 'openssl'
require 'base64'

module TrapWebhooks  
  module Routes
    class Travis < Sinatra::Base
      # Shamelessly ganked from https://github.com/travis-ci/webhook-signature-verifier
      # modified to log relevant info to Heroku app log

      def api_host
        # Free tier: https://api.travis-ci.org
        # Paid tier: https://api.travis-ci.com
        ENV.fetch('TRAVIS_API_HOST', 'https://api.travis-ci.org')
      end

      get '/travis' do
        status 200
        "[TRAP-WEBHOOKS:TRAVIS] Route Active!"
      end

      post '/travis' do
        begin
          json_payload = params.fetch('payload', '')
          signature    = request.env["HTTP_SIGNATURE"]

          pretty_payload = JSON.pretty_generate(JSON.parse(json_payload))

          puts "[TRAP-WEBHOOKS:TRAVIS] (PAYLOAD RECEIVED)\n#{pretty_payload}"

          pkey = OpenSSL::PKey::RSA.new(public_key)

          if pkey.verify(
              OpenSSL::Digest::SHA1.new,
              Base64.decode64(signature),
              json_payload
            )
            puts "[TRAP-WEBHOOKS:TRAVIS] (VERIFICATION) SUCCESS"
            status 200
          else
            puts "[TRAP-WEBHOOKS:TRAVIS] (VERIFICATION) FAILED"
            status 400
          end

        rescue => e
          logger.info "exception=#{e.class} message=\"#{e.message}\""
          logger.debug e.backtrace.join("\n")

          puts "[TRAP-WEBHOOKS:TRAVIS] (VERIFICATION) EXCEPTION"
          status 500
        end
      end

      def public_key
        conn = Faraday.new(:url => api_host) do |faraday|
          faraday.adapter Faraday.default_adapter
        end
        response = conn.get '/config'
        
        pretty_config = JSON.pretty_generate(JSON.parse(response.body))
        puts "[TRAP-WEBHOOKS:TRAVIS] (CONFIG FETCHED)\n#{pretty_config}"

        JSON.parse(response.body)["config"]["notifications"]["webhook"]["public_key"]
      rescue
        ''
      end
    end
  end
end