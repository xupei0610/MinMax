#
# This is the library file of Connect-Four
# This file contains a class named HumanAgent as the implement for human player.
#
# @author Pei Xu, 5186611
# @version 1.0.1

require_relative 'Agent'

module ConnectFour

  # An implement for human player
  class HumanAgent
    include Agent

    attr_accessor :name

    def to_s
      @name = 'Human Player' unless defined? @name and @name != nil
      @name
    end

    def move board, input_handle
      #while true
        move = input_handle.call
        #if (1..ConnectFour::Board::WIDTH).include? move
        #  break
        #end
      #end
      move-1
    end

  end

end
