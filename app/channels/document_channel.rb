# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
class DocumentChannel < ApplicationCable::Channel
  def subscribed
    @uuid = params[:uuid]
    @document_id = params[:document_id]
    reject and return unless @uuid && @document_id
    stop_all_streams
    stream_from "document:#{@document_id}"
    logger.info ">>> Subscribed #{@uuid} for doc #{@document_id}!"
    @subscribed = true
    user_connected
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    logger.info ">>> Unsubscribed #{@uuid}!"
    stop_all_streams
    @subscribed = false
    user_disconnected
  end

  def user_connected
    broadcast(event: "user_connected")
  end

  def user_disconnected
    broadcast(event: "user_disconnected")
  end

  def cursor_position_changed(payload)
    broadcast(event: "cursor_position_changed", cursor_position: payload["position"])
  end

  def content_changed(payload)
    broadcast(event: "content_changed", content: payload["content"])
  end

  private

  def broadcast(data)
    # ActionCable.server.broadcast "document_#{@document_id}", data
    DocumentChannel.broadcast_to "#{@document_id}", data.merge(uuid: @uuid)
  end
end
