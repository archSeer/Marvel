require 'bundler/setup'
Bundler.require

module Marvel; end
Dir["lib/**/*.rb"].each {|path| require_relative path }

module Marvel
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
end # end Marvel

Marvel::IP = %x{curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+'}

config = YAML.load_file("config.yml").symbolize_keys
hub = Marvel::Hub.new(config[:host], config[:port])

EM.run {
  EM.open_keyboard(Marvel::KeyboardHandler, hub)
  hub.connect!
  trap("INT") {
    hub.disconnect
    EM.add_timer(0.1) { EM.stop }
  }
}