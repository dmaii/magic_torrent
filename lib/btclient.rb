require_relative 'btclient/util'
require_relative 'btclient/tracker_request'
require_relative 'btclient/handshake'
require_relative 'btclient/client'
require_relative 'btclient/constants'
require_relative 'btclient/request'
require 'bencode'
require 'digest/sha1'
require 'httpclient'
include BTClient

file = File.open('./testdata/python.torrent')
#any port in the ephemeral range seems to work
port = '59696'
uploaded = 0
btclient = Client.new(file, port)
p btclient.info_hash['piece length']
p Util::piece_hashes(btclient.info_hash).size
their_handshake = btclient.perform_handshake
#indicate interest
btclient.socket.send("\0\0\0\x01\x02", 0)
message_length = btclient.socket.readpartial(4).unpack('C*')
message_type = btclient.socket.readpartial(1).unpack('C*')
raw_bitfield = btclient.socket.readpartial(message_length[3]).unpack('C*')
parsed_bitfield = Util::parse_bitfield raw_bitfield
p parsed_bitfield
p parsed_bitfield.size
puts btclient.socket.readpartial(9).inspect
#request = "\x00\x00\x00\r\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@\x00"
p Request.new(4, 0).download(btclient.socket).size
