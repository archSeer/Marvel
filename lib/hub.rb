class Marvel::Hub
  def initialize(host, port)
    @host = host
    @port = port

    @users = {}

    @hubname = nil
    @nick = 't3st'
    @op = false
    @login = false
  end

  def send command, msg=nil
    @connection.send_data "$#{command.to_s.camelize} #{msg}".strip
  end

  # replace &, | and $ with html entities.
  def sanitize string
    string.gsub('&', '&amp;').gsub('|', '&#124;').gsub('$', '&#36;')
  end

  def connect!
    @connection = EventMachine.connect(@host, @port, Marvel::Connection, self)
  end

  def disconnect
    send :quit, @nick
    @connection.close_connection(true)
  end

  def msg message
    @connection.send_data "<#{@nick}> #{sanitize(message)}"
  end

  def send_info
    interest = "Batman"
    tag = "<dCP++ V:0.8,M:P,H:3/0/0,S:4>"
    speed = "DSL3"
    email = "tests@test.com"
    sharesize = 1698351616 #698351616
    slots = "1/3"
    onlinetime = nil
    send "MyINFO $ALL", "#{@nick} #{interest}#{tag}$ $#{speed}$#{email}$#{sharesize}$#{slots}$#{onlinetime}$"
  end

  def handle_message(line)
    if data = line.match(/\$(?<command>\S+)\s+(?<params>.+)?/)
      params = data[:params].split(' ') if data[:params]
      event = Marvel::Event.new(self, data[:command], params)
      Marvel::Handler.handle_event(event)
    else
      print_console line
    end
  end

  def print_console(message)
    time = "[#{Time.now.strftime("%H:%M:%S")}]"
    puts "#{time.light_white} #{message}"
  end

  #=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
  # * Create a key from a lock.
  #-------------------------------------------  
  # By C Erler with suggestions by Robert Klemme.
  # Took the way of combining neighboring characters from the Python code.
  def create_key(lock)
    return '' unless lock.length >= 2

    # Transform the input bytes.
    bytes = lock.bytes.to_a
    result = Array.new(bytes.length) { |i| bytes[i - 1] ^ bytes[i] }
    result[0] ^= bytes[-2] ^ 5

    result.map! do |value|
      # Rotate each byte by four bits.
      value = ((value << 4) | (value >> 4)) & 0xff

      # Put the output in the correct format.
      case value
      when 0, 5, 36, 96, 124, 126
        '/%%DCN%03d%%/' % value
      else
        value.chr
      end
    end

    # Combine the parts into the resultant string.
    result.join
  end
end