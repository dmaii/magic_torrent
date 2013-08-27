require_relative 'btclient/util'
require_relative 'btclient/tracker_request'
require_relative 'btclient/handshake'
require_relative 'btclient/client'
require_relative 'btclient/constants'
require 'bencode'
require 'digest/sha1'
require 'httpclient'
include BTClient

request_length = "\0\0\0\x0d"
request_id = "\x06"
request_index = "\0\0\0\0"
request_offset = "\x00\x00\x00\x00"
block_length = "\x00\x00\100\x00"

file = File.open('./testdata/python.torrent')
#any port in the ephemeral range seems to work
port = '59696'
uploaded = 0
btclient = Client.new(file, port)
p btclient.pieces.size
their_handshake = btclient.perform_handshake
#indicate interest
btclient.socket.send("\0\0\0\x01\x02", 0)
message_length = btclient.socket.readpartial(4).unpack('C*')
message_type = btclient.socket.readpartial(1).unpack('C*')
raw_bitfield = btclient.socket.readpartial(message_length[3]).unpack('C*')
parsed_bitfield = Util::parse_bitfield raw_bitfield
p parsed_bitfield
p parsed_bitfield.size
request= request_length << request_id << request_index << request_offset << block_length
#request = "\x00\x00\x00\r\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@\x00"
puts 'request ' + request.inspect
btclient.socket.send(request, 0)
#puts btclient.socket.readpartial(16393).inspect
