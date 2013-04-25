require 'celluloid/zmq'

Celluloid::ZMQ.init

class Server
  include Celluloid::ZMQ

  def initialize(address)
    @socket = SubSocket.new

    begin
      @socket.subscribe('') # receive all
      @socket.connect(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def run
    loop { async.handle_message @socket.read }
  end

  def handle_message(message)
    puts "got message: #{message}"
  end
end

class Client
  include Celluloid::ZMQ

  def initialize(address)
    @socket = PubSocket.new
    @socket.linger = 100 # FIXME: Not sure what linger is for, read up

    begin
      @socket.bind(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def write(message)
    @socket.send(message)

    nil
  end
end

addr = 'tcp://127.0.0.1:3435'

server = Server.new(addr)
client = Client.new(addr)

sleep 1

server.async.run
client.write('hi')

sleep
