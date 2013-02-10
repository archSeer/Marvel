class Marvel::Connection < EventMachine::Connection
  def initialize hub
    @hub = hub
  end

  def send_data(data)
    super "#{data}|"
  end

  # Split commands at | and process them.
  def receive_data(data)
    (@buffer ||= BufferedTokenizer.new('|')).extract(data).each do |line|
      receive_line(line)
    end
  end

  def receive_line(line)
    @hub.handle_message(line)
  end
end