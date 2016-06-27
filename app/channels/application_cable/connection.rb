# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :uuid

    def connect
      self.uuid = SecureRandom.uuid
      puts "Setting random connection uuid (#{self.uuid})"
    end

    # identified_by :current_user

    # def connect
    #   self.current_user = find_verified_user
    #   logger.add_tags 'ActionCable', current_user.id
    # end
    #
    # protected
    #   def find_verified_user
    #     if verified_user = User.find_by(id: cookies.signed[:user_id])
    #       verified_user
    #     else
    #       reject_unauthorized_connection
    #     end
    #   end
  end
end
