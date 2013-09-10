module MagicTorrent
   class Handshake

      PSTRLEN = "\023"
      PSTR = "BitTorrent protocol"
      RESERVED = "\0\0\0\0\0\0\0\0"
         
      attr_accessor :info_hash, :peer_id, :socket

      def initialize(socket, info_hash)
         info_unhash = Digest::SHA1.hexdigest(info_hash.bencode)
         @info_hash = [info_unhash].pack('H*')
         @peer_id = [Digest::SHA1.hexdigest('a')].pack('H*')
         @socket = socket
      end 

      def send_and_receive
         ret = {}
         send_str = to_s
         @socket.send(send_str, 0)
         ret[:pstrlen] = @socket.recv(1)
         ret[:pstr] = @socket.recv(19)
         ret[:reserved] = @socket.recv(8)
         ret[:info_hash] = @socket.recv(20)
         ret[:peer_id] = @socket.recv(20)
         puts ret
         ret
      end 

      def to_s
         PSTRLEN << PSTR << RESERVED << @info_hash << @peer_id
      end 
   end 
end 
