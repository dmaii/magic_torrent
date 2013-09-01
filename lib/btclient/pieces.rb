module BTClient
  class Pieces
    attr_accessor :files, :length, :requests

    def initialize(files, length, requests = {}, req_length = nil)
      @files = files
      @length = length
      
      @total = files.inject(0) { |sum, file| sum += file['length'] }

      current_offset, current_index = 0
      until current_index.eql?(@total - 1)
        req = Request.new current_index, current_offset  
        req.length = req_length if req_length
        @requests << Request.new(i, current_offset)     
        if current_offset + req.length >= @length
          current_index += 1
        else
          current_offset += req.length
        end 
      end 
    end 
    
    # Downloads each piece into a hash keyed by 
    # the index of the piece. Each value contains
    # an array of downloaded strings for each request
    def download_range(s, e)
      r = {}
      @requests.each do |req|
        piece = r[req.req_index]
        r[piece] ||= [] 
        r[piece].push req.download
      end 
      r
    end 
  end 
end 
