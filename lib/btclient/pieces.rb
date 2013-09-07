require_relative 'request'

module BTClient
  class Pieces
    attr_accessor :files, :length, :requests, :total, :left

    # Files corresponds to the info hash's file key
    # Length corresponds to the info hash's piece length
    # Numbers used for the python torrent:
    # 14537518 = total bytes in torrent
    # 32768 = total bytes per piece
    # 16384 = total bytes per regular request
    # 21294 = remainder of 14537518 and 32768
    # 4910 = remainder of 21294 and 16384 (also 14537518 and 16384)
    def initialize(info_hash, requests = [], req_length = nil)
      # This is the byte length of a single file
      @length = info_hash['piece length']

      # The 'total' variable represents the total number of pieces.
      # Left is the byte length of the last piece
      if info_hash.has_key? 'files'
        @files = info_hash['files']

        # This is the total byte length of the torrent
        total_bytes = files.inject(0) { |sum, file| sum += file['length'] }
        @total = (total_bytes.to_f / @length).ceil
        @left = total_bytes % @length
      else
        # In a single file scenario, there's no 'files' key. There's
        # only a length, name, and hash field. The hash is not used here
        file_len = info_hash['length']
        @files = [ { length: file_len, name: info_hash['name'] } ]
        @total = (file_len.to_f / @length).ceil 
        @left = total_bytes % @length
      end 

      @requests = requests 

      puts total_bytes
      puts @length
      puts left

      # Create one request for every single piece
      total_counter = total_bytes || file_len
      piece_counter = @length
      current_offset = current_index = 0
      until current_index.eql? @total
        req = Request.new current_index, current_offset  

        # If it's the last piece, use the remainder 
        # from the total calculation
        # subtract one because total number of pieces is 1 indexed
        if total_counter < req.length
          require 'debugger'
          debugger
        end 
        # If last piece and remainder bit
        if total_counter <= @length
          req.length = total_counter
        # If there's a piece remainder, consume the remainder
        elsif piece_counter < req.length
          req.length = piece_counter
        else 
          req.length = req_length if req_length
        end 
        piece_counter -= req.length  
        @requests << req

        if piece_counter.eql? 0
          current_index += 1
          current_offset = 0
          piece_counter = @length
        else
          current_offset += req.length
        end 
        total_counter -= req.length
      end 
    end 
    
    # Downloads each piece into a hash keyed by 
    # the index of the piece. Each value contains
    # an array of downloaded strings for each request
    def download_range(s, e, socket)
      r = {}
      #target = @requests[s + 1, e]
      target = @requests.select do |req|
        req.req_index >= s && req.req_index <= e
      end 
      #require 'debugger'
      #debugger
      target.each do |req|
        piece = r[req.req_index]
        r[piece] ||= [] 
        r[piece].push(req.download(socket))
      end 
      r
    end 

  end 
end 
