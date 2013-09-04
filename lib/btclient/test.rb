require_relative 'util'
#boo
#p 17.to_4_byte_hex
#p 100.to_4_byte_hex
#p 40000.to_4_byte_hex
#p 16384.to_4_byte_hex

require 'net/http'

pages = %w( www.rubycentral.com
            www.awl.com
            www.pragmaticprogrammer.com
           )

threads = []

for page in pages
  threads << Thread.new(page) { |myPage|

    h = Net::HTTP.new(myPage, 80)
    puts "Fetching: #{myPage}"
    resp, data = h.get('/', nil )
    puts "Got #{myPage}:  #{resp.message}"
  }
end

threads.each { |aThread|  aThread.join }
