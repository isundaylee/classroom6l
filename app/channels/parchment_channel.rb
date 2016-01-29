# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class ParchmentChannel < ApplicationCable::Channel
  def subscribed
    @parchment_id = params['parchment_id'].to_i
    @parchment = Parchment.find(@parchment_id)
    @client_id = params['client_id']

    stream_from "parchment_#{@parchment_id}"
  end

  def unsubscribed
  end

  def submit_patch(data)
    logger.info "Processing patch to parchment ##{@parchment_id}: #{data['patch'].inspect}"

    if @parchment.apply_patch(data['patch'])
      transmitResponse data['seq'].to_i, true, {}
      broadcast 'patch', author: @client_id, patch: data['patch']
    else
      transmitResponse data['seq'].to_i, false, {}
    end
  end

  def sync(data)
    transmitResponse data['seq'].to_i, true, content: @parchment.content
  end

  private
    def broadcast_channel
      "parchment_#{@parchment_id}"
    end
end
