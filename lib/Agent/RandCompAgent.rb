#
# This is a library file of Connect-Four
# This file contains a class named RandCompAgent as the implement for a computer agent whose action pattern is random
#
# @author Pei Xu, 5186611
# @version 1.0.1

require_relative 'CompAgent'

module ConnectFour

  # An implement for a computer agent whose action pattern is random
  class RandCompAgent
     include CompAgent

     attr_accessor :name

     def to_s
      @name = 'Unpredictable Computer Player' unless defined? @name and @name != nil
      @name
     end


     # Randomly choose a move
     # @param board [ConnectFour::Board] the game board
     def move board
       top_row = board.board[ConnectFour::Board::HEIGHT-1]
       top_row.each_index.select{|i| top_row[i] == ConnectFour::Board::EMPTY_SLOT}.sample
     end

  end

end
