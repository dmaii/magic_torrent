class Peer

  INTEREST = "\0\0\0\x01\x02"
  KEEP_ALIVE = "\0\0\0\0"

  attr_accessor :bitfield

  def initialize(id, ip, port)
    @id = id
    @socket = TCPSocket.new ip, port
  end 

  def interested
    @socket.send(INTEREST, 0)
    message_length = @socket.readpartial(4).unpack('C*')
    unless message_length.eql? KEEP_ALIVE
      message_type = @socket.readpartial(1).unpack('C*')
      case message_type
      when 5
        raw_bitfield = @socket.readpartial(message_length[3]).unpack('C*')
        @bitfield = Util::parse_bitfield raw_bitfield
      else
        #handle this later
      end 
    end 
    Util::MSG_TYPE[message_type] || 'keep alive'
  end 
end 
