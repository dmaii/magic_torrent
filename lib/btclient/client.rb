include BTClient

module BTClient
  class Client
    attr_accessor :torrent, :info_hash, :socket, :unbencoded_torrent

    def initialize(torrent, port)
      @torrent = torrent
      @port = port

      raw_torrent = @torrent.read
      parser = BEncode::Parser.new(StringIO.new(raw_torrent))
      @unbencoded_torrent = parser.parse!
      @info_hash = @unbencoded_torrent['info']
    end 

    def connect_to_tracker
      peer_hash = Digest::SHA1.hexdigest 'a'
      peer = Util::percent_encode_hash(peer_hash).force_encoding('binary')
      req = TrackerRequest.new @unbencoded_torrent , @port, ZERO_UPLOAD, peer
      req.send_and_receive
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

    # Downloads the file at this index on 'files'
    # inside the info hash
    def download_file(index)
      files = @info_hash['files']
      prev_files = files.take index
      prev_len= prev_files.reduce { |s, file| sum += file['length'] }
    end 

    def indicate_interest
      @socket.send(BTClient::INTEREST, 0)
    end 
  end 
end 
