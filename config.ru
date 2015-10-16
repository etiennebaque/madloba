# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# Configuration related to Faye Websocket
if defined?(::Thin)
  Faye::WebSocket.load_adapter('thin')
elsif defined?(::PhusionPassenger)
  PhusionPassenger.advertised_concurrency_level = 0
end

run Madloba::Application
