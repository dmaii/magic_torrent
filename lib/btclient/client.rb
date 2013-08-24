include BTClient

module BTClient
   class Client
      attr_accessor :torrent, :info_hash

      def initialize(torrent, port)
         @torrent = torrent
         @port = port

         raw_torrent = @torrent.read
         parser = BEncode::Parser.new(StringIO.new(raw_torrent))
         @unbencoded_torrent = parser.parse!
         @info_hash = @unbencoded_torrent['info']
      end 

      def connect_to_tracker
         peer_id = Util::percent_encode_hash(
            Digest::SHA1.hexdigest('a')).force_encoding('binary')

         parsed_response = TrackerRequest.new(
            @unbencoded_torrent , @port, BTClient::ZERO_UPLOAD, peer_id
         ).send_and_receive

         parsed_response
      end 

   end 

   # TODO: Implement this
   def perform_handshake
   end 
end 
