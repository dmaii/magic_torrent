require_relative 'magic_torrent/util'
require_relative 'magic_torrent/tracker_request'
require_relative 'magic_torrent/handshake'
require_relative 'magic_torrent/controller'
require_relative 'magic_torrent/pieces'
require 'bencode'
require 'digest/sha1'
require 'httpclient'
include MagicTorrent

file = File.open('./testdata/python.torrent')
#any port in the ephemeral range seems to work
port = rand 49152..65535
uploaded = 0
magic_torrent = Controller.new(file, port)
their_handshake = magic_torrent.perform_handshake
#indicate interest
magic_torrent.socket.send("\0\0\0\x01\x02", 0)
message_length = magic_torrent.socket.readpartial(4).unpack('C*')
message_type = magic_torrent.socket.readpartial(1).unpack('C*')
raw_bitfield = magic_torrent.socket.readpartial(message_length[3]).unpack('C*')
parsed_bitfield = Util::parse_bitfield raw_bitfield
p parsed_bitfield
p parsed_bitfield.size
puts magic_torrent.socket.readpartial(9).inspect
#request = "\x00\x00\x00\r\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00@\x00"
#p Request.new(4, 0).download(magic_torrent.socket).size

# Instantiate Pieces
#request = "\x00\x00\x00\r\x06\x00\x00\e\b\x00\x00\x00\x00\x00\x00@\x00"

#magic_torrent.socket.send(Request.new(440, 0).to_s, 0)
#p magic_torrent.socket.readpartial(1024*16)
magic_torrent.download_file 3
