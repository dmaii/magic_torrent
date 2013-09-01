module BTClient
  class Pieces
    include Enumerable
    attr_accessor :index, :length

    def initialize(index, length)
      @index = index
      @length = length
    end 
  end 
end 
