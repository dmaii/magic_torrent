require_relative 'util'
require_relative 'piece_request'
include BTClient

p '16'.convert_base(10, 16)
p ['79'.hex].pack("C*")

a = PieceRequest.new(0, 0)
p a.as_hex('req_offset').inspect
p a.to_s
