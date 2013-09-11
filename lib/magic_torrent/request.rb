require_relative 'util'

include MagicTorrent

module MagicTorrent
  class Request
    # BT requests are always six
    REQ_ID = 6
    # 16kb is the standard piece length
    STD_PIECE_LEN = 16384
    # Msg length is always 13
    MSG_LEN = "\0\0\0\x0d"
    attr_accessor :length, :id, :index, :offset

    def initialize(req_index, req_offset)
      @length = STD_PIECE_LEN 
      @id = REQ_ID
      @index = req_index
      @offset = req_offset
      @downloaded = false
    end 

    def to_hex
      r = MSG_LEN + as_hex('id') + as_hex('index') + 
        as_hex('offset') + as_hex('length')
      r
    end 

    def as_hex(attr_name)
      if attr_name.eql? 'id'
        id.to_s(16).hexify
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
      (1..4-twos.size).each { r << Util::NULL }
      twos.each { |two| r << two.hexify }
      r
    end 

    def download(socket, id=nil, len=nil)
      @id = id if id
      @length = len if len
      socket.send(self.to_hex, 0)

      # Reads data from the socket until 16kb is reached
      read_size = 0
      r = ''
      until read_size >= (4 + @length) 
        current_read = socket.readpartial(1024*16)
        current_size = current_read.size
        r << current_read
        read_size += current_size
      end 
      @downloaded = true
      # The first 13 characters are going to be part of the piece
      # message, and aren't actually part of the data
      r[13..-1]
    end 
  end 
end
