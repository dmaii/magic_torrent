require_relative 'constants'
include BTClient

module BTClient
  class PieceRequest
    # BT requests are always six
    REQ_ID = 6
    # 16kb is the standard piece length
    STD_PIECE_LEN = 16384
    # Msg length is always 13
    MSG_LEN = "\0\0\0\x0d"
    attr_accessor :piece_length, :req_id, :req_index,
                  :req_offset
    
    def initialize(req_index, req_offset)
      @piece_length = STD_PIECE_LEN 
      @req_id = REQ_ID
      @req_index = req_index
      @req_offset = req_offset
    end 

    def to_s
      p 'index' + as_hex('req_index')
      MSG_LEN + as_hex('req_id') + as_hex('req_index') + 
        as_hex('req_offset') + as_hex('piece_length')
    end 

    def as_hex(attr_name)
      if attr_name.eql? 'req_id'
        req_id.to_s(16).hexify
      else
        self.send(attr_name).to_4_byte_hex  
      end
    end 

    # Converts an integer to a 4 byte hex
    def int_to_4bytehex(int)
      r = ''
      if int.to_s(16).size > 1
        twos = int.to_s(16).scan(/../)
      else 
        twos = [int.to_s(16)]
      end
      (1..4-twos.size).each { r << NULL }
      twos.each { |two| r << two.hexify }
      r
    end 
  end 
end
