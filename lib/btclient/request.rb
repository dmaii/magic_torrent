require_relative 'constants'
include BTClient

module BTClient
  class Request
    # BT requests are always six
    REQ_ID = 6
    # 16kb is the standard piece length
    STD_PIECE_LEN = 16384
    # Msg length is always 13
    MSG_LEN = "\0\0\0\x0d"
    attr_accessor :length, :req_id, :req_index,
      :req_offset

    def initialize(req_index, req_offset)
      @length = STD_PIECE_LEN 
      @req_id = REQ_ID
      @req_index = req_index
      @req_offset = req_offset
    end 

    def to_s
      r = MSG_LEN + as_hex('req_id') + as_hex('req_index') + 
        as_hex('req_offset') + as_hex('length')
      r
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

    def download(socket, id=nil, len=nil)
      @req_id = id if id
      @length = len if len
      socket.send(self.to_s, 0)

      # Reads data from the socket until 16kb is reached
      read_size = 0
      r = ''
      until read_size >= (4 + @length) 
        current_read = socket.readpartial(1024*16)
        current_size = current_read.size
        r << current_read
        read_size += current_size
      end 
      r
    end 
  end 
end
