include BTClient

module BTClient
  class Client
    attr_accessor :torrent, :info_hash, :socket,
                  :unbencoded_torrent

    def initialize(torrent, port)
      @torrent = torrent
      @port = port

      raw_torrent = @torrent.read
      parser = BEncode::Parser.new(StringIO.new(raw_torrent))
      @unbencoded_torrent = parser.parse!
      @info_hash = @unbencoded_torrent['info']
    end 

    def connect_to_tracker
      peer_id = Util::percent_encode_hash(
        Digest::SHA1.hexdigest('a')).force_encoding('binary')

      parsed_response = TrackerRequest.new(
        @unbencoded_torrent , @port, BTClient::ZERO_UPLOAD, peer_id
      ).send_and_receive

      parsed_response
    end 

  end 

  def perform_handshake
    tracker_response = connect_to_tracker          
    # Grab ip of first peer
    # TODO: Make this handle more than one peer
    ip = tracker_response['peers'][0]['ip']
    port = tracker_response['peers'][0]['port']
    @socket = TCPSocket.new ip, port
    our_handshake = Handshake.new(@socket, @info_hash)
    our_handshake.send_and_receive
  end 

  def indicate_interest
    @socket.send(BTClient::INTEREST, 0)
  end 
  
end 
