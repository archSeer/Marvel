require 'bundler/setup'
Bundler.require

module Marvel; end
Dir["lib/**/*.rb"].each {|path| require_relative path }

module Marvel
  include ActiveSupport::Configurable

  class KeyboardHandler < EventMachine::Connection
    include EM::Protocols::LineText2
    def initialize hub
      @hub = hub
    end

    def receive_line keystrokes
      print "=> #{@hub.instance_eval(keystrokes).inspect}\n> "
    rescue Exception => err
      puts err
    end
  end

  IP = %x{curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+'}

  self.config.merge! YAML.load_file("config.yml").symbolize_keys
end

cfg = Marvel.config.hub
hub = Marvel::Hub.new(cfg["host"], cfg["port"])

EM.run {
  EM.open_keyboard(Marvel::KeyboardHandler, hub)
  hub.connect!
  trap("INT") {
    hub.disconnect
    EM.add_timer(0.1) { EM.stop }
  }
}