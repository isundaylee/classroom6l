# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected
      def transmitResponse(seq, success, payload)
        transmit success: success, seq: seq, payload: payload
      end

      def broadcast(type, payload)
        ActionCable.server.broadcast broadcast_channel, {type: type, payload: payload}
      end
  end
end
