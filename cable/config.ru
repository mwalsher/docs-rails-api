# Note: the servers seem to perpetually restart (i.e. when `rails s` and `bin/cable` are ran at the same time) unless config/puma.rb are removed.
# This is no longer necessary however as cables can be ran through the regular puma server
require ::File.expand_path('../../config/environment', __FILE__)
Rails.application.eager_load!

run ActionCable.server
