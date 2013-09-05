require_relative 'request'

module BTClient
  class Pieces
    attr_accessor :files, :length, :requests, :total, :left

    # Files corresponds to the info hash's file key
    # Length corresponds to the info hash's piece length
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

      # Create one request for every single piece
      current_offset = current_index = 0
      until current_index.eql? @total
        req = Request.new current_index, current_offset  
        req.length = req_length if req_length

        # If it's the last piece, use the remainder 
        # from the total calculation
        if current_index.eql? @total - 1
          req_length = left
        else 
          req.length = req_length if req_length
        end 

        @requests << Request.new(current_index, current_offset)     
        if current_offset + req.length >= @length
          current_index += 1
          current_offset = 0
        else
          current_offset += req.length
        end 
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
      target.each do |req|
        piece = r[req.req_index]
        r[piece] ||= [] 
        r[piece].push(req.download(socket))
      end 
      r
    end 

  end 
end 
