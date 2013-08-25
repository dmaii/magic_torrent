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
request_offset = "\x00\x00\x40\x00"
block_length = "\x00\x00\x40\x00"

file = File.open('./testdata/python.torrent')
#any port in the ephemeral range seems to work
port = '59696'
uploaded = 0
btclient = Client.new(file, port)
their_handshake = btclient.perform_handshake
btclient.socket.send("\0\0\0\x01\x02", 0)
#puts btclient.socket.readpartial(8).inspect
message_header = btclient.socket.readpartial(5).unpack('C*')
puts btclient.socket.readpartial(message_header[3]).to_i(2)
puts btclient.socket.readpartial(9).inspect
request= request_length << request_id << request_offset << block_length

puts request_offset.inspect
btclient.socket.send(request, 0)
puts btclient.socket.readpartial(16393)
