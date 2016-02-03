require 'faye/websocket'

class ActionCableProxy
  def initialize(app, options={})
    @app = app
    ActionCable.server.config.allowed_request_origins = [ENV['ACTIONCABLE_URL'].gsub('ws:', 'http:')] unless ENV['ACTIONCABLE_URL'].nil?
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ActionCable.server.call(env)
    else
      @app.call(env)
    end
  end
end