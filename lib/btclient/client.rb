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
      prev_pieces = 0

      if @info_hash.has_key? 'files'
        files = @info_hash['files']
        filename = files[index]['path'].join('/') 
      end 
      pieces = Pieces.new @info_hash
      if index > 0
        prev_files = files.take index
        post_files = files.drop index + 1
        #prev_len= prev_files.inject(0) { |s, file| s += file['length'] }
        prev_len = calc_file_lengths prev_files
        post_len = calc_file_lengths post_files
        prev_pieces = prev_len / pieces.length - 1
        file_length = files[index]['length']
        file_pieces = (file_length.to_f / pieces.length).ceil
        piece_len = files['piece length']
        prev_in_piece = prev_len % piece_len
        post_in_piece = post_len % piece_len
        e = prev_pieces + file_pieces 
      else
        filename = @info_hash['name']
        file_length = @info_hash['length']
        e = pieces.total - 1
      end 

      f = File.open("./#{filename}", 'w')
      puts 'prev ' + prev_pieces.to_s
      puts 'e ' + e.to_s
      downloaded = pieces.download_range(prev_pieces || 0, e, @socket)   
      f.write(downloaded.values.join)
      f.close_write
      p 'hello warudo'
    end 

    def indicate_interest
      @socket.send(BTClient::INTEREST, 0)
    end 

    def calc_file_lengths(file_hashes)
      file_hashes.inject(0) { |s, file| s += file['length'] }
    end 
  end 
end 
