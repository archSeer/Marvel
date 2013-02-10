class Marvel::Event
  attr_accessor:hub, :command, :params
  def initialize(hub, command, params)
    @hub = hub
    @command = command.underscore.to_sym
    @params = params
  end
end