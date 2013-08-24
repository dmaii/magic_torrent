require_relative 'btclient/util'
require_relative 'btclient/tracker_request'
require_relative 'btclient/handshake'
require_relative 'btclient/client'
require 'bencode'
require 'digest/sha1'
require 'httpclient'
include BTClient

file = File.open('./testdata/python.torrent')
#any port in the ephemeral range seems to work
port = '59696'
uploaded = 0
btclient = Client.new(file, port)
parsed_response = btclient.connect_to_tracker
info_hash = btclient.info_hash
ip = parsed_response['peers'][0]['ip']
port = parsed_response['peers'][0]['port']

client = TCPSocket.new ip, port
our_handshake = Handshake.new(client, info_hash)
their_handshake = our_handshake.send_and_receive

client.send("\0\0\0\x01\x02", 0)
puts client.readpartial(8).inspect

