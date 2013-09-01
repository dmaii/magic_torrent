module Util

  # Adds a percentage symbol every two characters
  # in order to make a hash URL friendly
  def self.percent_encode_hash(hash)
    hash = hash.upcase.split('')
    r = []
    c = 0
    until hash.empty?
      c = 0 if c >= 2
      r << '%' if c.eql? 0
      r << hash.shift
      c += 1
    end
    r.join('')
  end 

  def self.percent_to_hash(percent_encoded)
    start_array = percent_encoded.split('')
    r = []
    while not start_array.empty?
      c = start_array.first
      if c.eql? '%'
        start_array.shift
        r << start_array.shift.downcase
        r << start_array.shift.downcase
      else
        r << start_array.shift.unpack('H*').join
      end
      #puts r.to_s
    end 
    r
  end 

  # Gets all the lengths from the files array of
  # of hashes, and sums up the lengths to get the
  # total length of a file
  def self.sum_lengths(info_files)
    sum = info_files.inject(0) do |sum, hash|
      sum += hash['length']
    end 
    sum
  end 

  def self.hash_to_url(hash)
    r = '?'
    hash.each_with_index do |(key, value), index|
      r << '&' if not index.eql? 0
      r << key.to_s << '=' << value.to_s
    end 
    r
  end 

  def self.parse_bitfield(hexes)
    bins = hexes.collect { |hex| hex.to_s(2) }
    bins.join.split('')
  end 

  # Gets the hashes of the pieces from the info_hash
  def self.piece_hashes(info_hash)
    pieces = info_hash['pieces'].scan(/.{20}/)
    pieces.collect { |hash| hash.unpack('H*').join }
  end 

end 

class String
  def convert_base(from, to)
    self.to_i(from).to_s(to)
  end

  def remove_hex_escape
    self.unpack('H*').first
  end 

  # Turns a hex string into \x{hex} format
  def hexify
    [self.hex].pack('C*')
  end 

end

class Fixnum
  def to_4_byte_hex
    r = ''
    if self.to_s(16).size > 1
      twos = self.to_s(16).partition(/../).reject { |i| i.empty? }
    else 
      twos = [self.to_s(16)]
    end
    (1..4-twos.size).each { r << NULL }
    twos.each { |two| r << two.hexify }
    r
  end 
end 
