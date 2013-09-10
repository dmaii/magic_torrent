class Peer
  def initialize(id, ip, port)
    @id = id
    @socket = TCPSocket.new ip, port
  end 

end 
