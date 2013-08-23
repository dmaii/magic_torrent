## world's smallest bittorrent client
require 'rubytorrent'
bt = RubyTorrent::BitTorrent.new(ARGV.shift)
 
thread = Thread.new do
  while true
    puts bt.percent_completed
    sleep 15
  end
end
bt.on_event(self, :complete) { thread.kill }
thread.join
