require "kemal"
require "kemal-basic-auth"
require "./apis/*"

module Hpr::API
  CLIENT = Client.new

  def self.run(port = 8848)
    enable_auth = Hpr.config.basic_auth.enable
    if enable_auth
      basic_auth Hpr.config.basic_auth.user, Hpr.config.basic_auth.password
    end

    Hpr.logger.info "API Server now listening at localhost:#{port}#{enable_auth ? " (basic auth)" : ""}, press Ctrl-C to stop"

    Kemal.run(port) do |config|
      config.env = "production"
    end
  end

  include Entrance
  include Repository
end
