include MagicTorrent

module MagicTorrent


  class Controller
    attr_accessor :torrent, :info_hash, :socket, :unbencoded_torrent, 
      :bitfield

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
        puts files
        filename = files[index]['path'].join('/') 
      end 
      p = Pieces.new @info_hash
      # All you need are here are the starting piece, starting byte,
      # ending piece, and ending byte

      if @info_hash.has_key? 'files'
        file_loc = file_location index
        s_piece, s_byte, e_piece, e_byte = file_loc.values
      end 

      f = File.open("./#{filename}", 'w')
      downloaded = p.download_range(s_piece || 0, e_piece, @socket)   
      puts downloaded.values.join[s_byte, e_byte].size
      f.write(downloaded.values.join[s_byte..e_byte])
      f.close_write
    end 

    
    # Get the total byte length of an array of files
    def calc_file_lengths(file_hashes)
      file_hashes.inject(0) { |s, file| s += file['length'] }
    end 

    # This method calculates, for a certain info hash and 
    # file index, which piece to start downloading at, which
    # piece to stop downloading at, which byte on the starting
    # piece to write to the file, and which byte on the ending
    # piece to stop writing to the file. This method is only
    # for multi file torrents
    def file_location(index)
      r = {}
      files = @info_hash['files']
      piece_bytes = @info_hash['piece length']

      prev_bytes = calc_file_lengths(files.take(index))
      file_bytes = files[index]['length']
      post_bytes = calc_file_lengths(files.drop(index + 1)) 

      # Not adding one to starting piece and byte to account for 
      # 0 index
      r[:starting_piece] = prev_bytes / piece_bytes 
      starting_offset = prev_bytes % piece_bytes
      r[:starting_byte] = starting_offset 

      if starting_offset + file_bytes > piece_bytes 
        oflow_bytes = starting_offset + file_bytes - piece_bytes  
        oflow_pieces, oflow_remainder = oflow_bytes.divmod piece_bytes 
        r[:ending_piece] = starting_piece + oflow_pieces
      else
        r[:ending_piece] = r[:starting_piece]
      end 
      r[:ending_byte] = starting_offset + file_bytes
      r
    end 
  end 
end 
