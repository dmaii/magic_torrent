def percent_encode_hash(hash)
   hash = hash.upcase.split('')
   ret = []
   c = 0
   while not hash.empty?
      c = 0 if c >= 2
      ret << '%' if c.eql? 0
      ret << hash.shift
      c += 1
   end
   ret.join('')
end 

def percent_to_hash(percent_encoded)
   start_array = percent_encoded.split('')
   ret = []
   while not start_array.empty?
      c = start_array.first
      if c.eql? '%'
         start_array.shift
         ret << start_array.shift.downcase
         ret << start_array.shift.downcase
      else
         ret << start_array.shift.unpack('H*').join
      end
      #puts ret.to_s
   end 
   ret
end 

def sum_lengths(info_files)
   sum = info_files.inject(0) do |sum, hash|
      sum += hash['length']
   end 
   sum
end 

def hash_to_url(hash)
   ret = '?'
   hash.each_with_index do |(key, value), index|
      ret << '&' if not index.eql? 0
      ret << key.to_s << '=' << value.to_s
   end 
   ret
end 

