require_relative 'util'
require 'httpclient'

module MagicTorrent

   ZERO_UPLOAD = 0

   class TrackerRequest
      attr_accessor :info, :announce, :announce_list, :creation_date,
         :comment, :encoding, :uploaded, :port, :peer_id

      def initialize(torrent_hash, port, uploaded, peer_id)
         @info = torrent_hash['info']   
         @announce = torrent_hash['announce']   
         @comment = torrent_hash['comment']
         @creation_date = torrent_hash['creation date']
         @locale = torrent_hash['locale']
         @title = torrent_hash['title']
         @uploaded = uploaded
         @peer_id = peer_id
         @port = port
         @left = Util::sum_lengths(info['files'])
      end 

      # Returns the parsed announce file sent from the tracker
      # as a hash
      def send_and_receive
         url = to_s
         raw_response = HTTPClient.new.get(url).body
         parsed_response = BEncode::Parser.new(StringIO.new(raw_response))
         parsed_response.parse!
      end 

      def to_s
         @announce << Util::hash_to_url(url_hash)
      end 

      def url_hash
         info_hash = Digest::SHA1.hexdigest(@info.bencode)
         info_hash = Util::percent_encode_hash(info_hash)
         info_hash = info_hash.force_encoding('binary')
         { uploaded: @uploaded, 
            info_hash: info_hash,
            peer_id: @peer_id, 
            port: @port, 
            left: @left }
      end 
   end 
end 
