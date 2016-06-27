# module SessionTesty
#   # def POST # =(*args)
#   # def self.normalize_encode_params(*args)
#   def request(*args)
#     binding.pry
#     result = super(*args)
#     binding.pry
#   end
# end

# class ActionDispatch::Integration::Session
# class Rack::Test::Session
# class Rack::MockSession
# class ActionDispatch::Request
# module ActionDispatch::Http::Parameters
# class ActionDispatch::Request::Utils
# class ActionController::Parameters
# class ActionDispatch::TestRequest
# class ActionDispatch::Http::Headers
#  prepend SessionTesty
#
#  # def self.from_hash(*args)
#  #   binding.pry
#  # end
#end

module RequestHelpers
  %i[get post patch put delete].each do |method|
    define_method "#{method}_with_token" do |path, token:, params: {}, headers: {}|
      send_request_with_token(method: method, path: path, params: params, headers: headers, token: token)
    end
  end

  def send_request_with_token(method:, path:, token:, params: {}, headers: {})
    headers.merge!('Authorization' => authorization_token_header(token)) if token
    headers.merge!('Content-Type' => 'application/vnd.api+json')
    if method == :get
      # Hack around Rails bug with params not being parsed from JSON with get requests
      send(method, path, params: params, headers: headers)
    else
      send(method, path, params: params, headers: headers, as: :json)
    end
    response
  end

  def authorization_token_header(token)
    "Token token=\"#{token}\""
  end
end
