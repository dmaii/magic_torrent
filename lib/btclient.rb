require_relative 'util'
require 'bencode'
require 'digest/sha1'
require 'httpclient'


file = File.open('./python.torrent').read
s=BEncode::Parser.new(StringIO.new(file))
a = s.parse!
info = a['info']
info_hash = percent_encode_hash(Digest::SHA1.hexdigest(a['info'].bencode)).force_encoding('binary')
announce = a['announce']
peer_id = percent_encode_hash(Digest::SHA1.hexdigest('a')).force_encoding('binary')
left = sum_lengths(info['files'])
#any ip seems to work
ip = '00.00.00.00'
#any port in the ephemeral range seems to work
port = '59696'
uploaded = 0

url_hash = {uploaded: uploaded, info_hash: info_hash, peer_id: peer_id, port: port, left: left}

final_url = announce << hash_to_url(url_hash)
http_client = HTTPClient.new
response = http_client.get(final_url).body

parsed_response = BEncode::Parser.new(StringIO.new(response)).parse!
ip = parsed_response['peers'][0]['ip']
port = parsed_response['peers'][0]['port']

pstrlen = 19.to_s(16)
pstr = 'BitTorrent protocol'.bytes.inject('') { |pstr, c| pstr << c.to_s }
info_hash = Digest::SHA1.hexdigest(a['info'].bencode)

#info_hash = info_hash.each_byte.map { |b| '\0' + b.to_s(16) }.join
#info_hash = ",\x98c\xB7w\xDB\xC9\r\xDE\xBCE\xBD\x9F\xFD\x99]+\xB8US" 

#ip = '127.0.0.1'
#port = '4481'
#info_hash = ",\x98c\xb7w\xdb\xc9\r\xde\xbcE\xbd\x9f\xfd\x99]+\xb8US"
client = TCPSocket.new ip, port
peer_id = [Digest::SHA1.hexdigest('a')].pack('H*')
info_hash = [info_hash].pack('H*')
#client.send("\023BitTorrent protocol\x00\x00\x00\x00\x00\x00\x00\x00", 0)
client.send("\023BitTorrent protocol\0\0\0\0\0\0\0\0", 0)
client.send("#{info_hash}#{peer_id}", 0)
len = client.recv(1)[0]
puts len.unpack('C*').join
name = client.recv(19)
puts name
reserved = client.recv(8)
puts reserved.inspect
their_hash = client.recv(20)
puts their_hash.unpack('H*')
their_peer_id = client.recv(20)
puts their_peer_id.unpack('H*')
