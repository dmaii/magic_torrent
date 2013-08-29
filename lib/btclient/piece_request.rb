module BTClient
  class PieceRequest
    # BT requests are always six
    REQ_ID = 6
    # 16kb is the standard piece length
    STD_PIECE_LEN = 16384
    attr_accessor :piece_length, :req_id, :req_index,
                  :req_offset, :block_length
    def initalize(piece_length, req_index, req_offset)
      @piece_length = STD_PIECE_LEN 
      @req_index = req_index
      @req_offset = req_offset
    end 

    def 
  end 
end
