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
    name = Document.create_name
    set_user(@uuid, {name: name})
    broadcast(event: "user_connected", name: name, users: users)
  end

  def user_disconnected
    remove_user(@uuid)
    broadcast(event: "user_disconnected", users: users)
  end

  def cursor_position_changed(payload)
    broadcast(event: "cursor_position_changed", cursor_position: payload["position"])
  end

  def content_changed(payload)
    Document.find(@document_id).update_attributes(text: payload["content"])
    # puts "#{@document.text}, #{@document.id}, #{@document_id}, #{payload["content"]}"
    broadcast(event: "content_changed", content: payload["content"])
  end

  def greeting(payload)
    broadcast(event: "greeting", cursor_position: payload["position"], name: payload["name"])
  end

  private

  def broadcast(data)
    # ActionCable.server.broadcast "document_#{@document_id}", data
    DocumentChannel.broadcast_to "#{@document_id}", data.merge(uuid: @uuid)
  end

  def users
    users_serialized = redis.get(:users)
    if users_serialized.present?
      users = JSON.parse(users_serialized)
    else
      users = nil
    end

    users.try(:with_indifferent_access) || Hash.new
  end

  def set_user(uuid, value)
    h = users
    h[uuid] = value
    ap h
    h.compact!
    redis.set(:users, h.to_json.presence)
    value
  end

  def remove_user(uuid)
    set_user(uuid, nil)
  end

  def redis
    return @redis if @redis
    redis_config = Rails.application.config.settings["redis"]
    raise ArgumentError.new("redis_url must be set in settings.yml") unless redis_config
    @redis = Redis.new(redis_config)
  end
end
