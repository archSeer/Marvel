module Marvel::Handler
  # Contains all of our event listeners.
  @@event_listeners = {:all => []}

  # Adds a new event listener.
  # @param [Symbol] command The command to listen for.
  # @param [*Array] args A list of arguments.
  # @param [Proc] block The block we want to execute when we catch the command.
  def self.on command,*args,&block
    listeners = @@event_listeners[command] ||= []
    block ||= proc { nil }
    args.include?(:prepend) ? listeners.unshift(block) : listeners.push(block)
  end

  # Passes the event on to any event listeners that are listening for this command.
  # All events get passed to the +:all+ listener.
  # @param [Event] event The event that was recieved.
  def self.handle_event event
    execute = lambda { |block| event.hub.instance_exec(event.dup, &block) }
    @@event_listeners[:all].each(&execute) # Execute before every other handle
    @@event_listeners[event.command].each(&execute) if @@event_listeners.has_key?(event.command)
  end

  on :lock do |event|
    send :key, "#{create_key(event.params.first)}"
    send :validate_nick, @nick
  end

  on :loged_in do |event|
    @op = true
  end

  on :hello do |event|
    if event.params.first == @nick
      @login = true
      send :version, "1.0091"
      send_info
      send :get_nick_list
    else
    end
  end

  on :nick_list do |event|
    @users.clear
    event.params.first.split("&&") do |nick|
      @users[nick] = {op => false}
    end
  end

  on :op_list do |event|
    event.params.first.split("&&") do |op|
      @users[nick][op] = true
    end
  end

  on :hub_name do |event|
    @hubname = event.params.first
  end
end