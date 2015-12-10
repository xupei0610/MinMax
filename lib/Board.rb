#
# This is the library file of Connect-Four.
# This file contains a class named Board as the implement for the game board of Connect-Four.
#
# @author Pei Xu, 5186611
# @version 1.0.1

module ConnectFour

  # An implement for the game board of Connect-Four
  class Board

    WIDTH = 7
    HEIGHT = 6

    PLAYER1 = 1
    PLAYER2 = 2
    EMPTY_SLOT = 0

    WIN = 1
    DRAW = 0
    GAMEOVER = 2

    attr_reader :board, :game_status, :player1, :player2

    # Initialize the game board.
    def initialize player1_agent, player2_agent
      @board = Array.new HEIGHT do
        Array.new WIDTH, EMPTY_SLOT
      end

      # the column at which the last move is made
      @last_move = nil
      # the player who made the last move
      # set to PLAYER2 initially so that the first move will be made by PLAYER1
      @last_player = PLAYER2

      # game status, nil or GAMEOVER
      @game_status = nil

      # They are used for some cases in which it is needed to identify if an agent is player1 or 2
      @player1 = player1_agent
      @player2 = player2_agent

    end

    # Place a check at the given column
    # @param column [Integer] column is counted from 0
    # @yield
    # @return
    def place column
      if @game_status == GAMEOVER
        raise SecurityError, 'Game has been over. No new placement is acceptable.'
      end
      HEIGHT.times do |r|
        if @board[r][column] == EMPTY_SLOT
          @last_player = @last_player==PLAYER2 ? PLAYER1 : PLAYER2
          @board[r][column] = @last_player
          @last_move = column
          yield true
          if self.class::who_win? @board
            @game_status = GAMEOVER
            yield WIN
          end
          if self.class::draw? @board
            @game_status = GAMEOVER
            yield DRAW
          end
          return true
        end
      end if column.is_a? Integer and column < WIDTH and column > -1
      yield false
      false
    end


    def self.draw? board
      draw = true
      HEIGHT.times do |r|
        if board[r].include? EMPTY_SLOT
          draw = false
          break
        end
      end
      draw
    end

    def self.who_win? board
      rows = board.map{|r| r.join}
      cols = board.transpose.map{|c| c.join}

      left_revolved_board = Array.new
      right_revolved_board = Array.new
      HEIGHT.times do |r|
        left_revolved_board << ([nil] * r + board[r] + [nil] * (HEIGHT-1-r))
        right_revolved_board << ([nil] * (HEIGHT-1-r) + board[r] + [nil] * r)
      end
      diags = (left_revolved_board+right_revolved_board).transpose.map{|d| d.join}

      (rows+cols+diags).each do |r|
        return PLAYER1 if r.include? PLAYER1.to_s*4
        return PLAYER2 if r.include? PLAYER2.to_s*4
      end

      nil

    end


  end
end
