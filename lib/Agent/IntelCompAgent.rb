#
# This is a library file of Connect-Four.
# This file contains a class named IntelCompAgent as the implement for a computer agent whose action pattern is determined via min-max algorithm.
#
# @author Pei Xu, 5186611
# @version 1.0.1

module ConnectFour

  # An implement for a computer agent whose action pattern is determined via min-max algorithm
  class IntelCompAgent
    include CompAgent

    INF = 10000

    attr_reader :iq
    attr_accessor :name

    def initialize iq = 1
      @iq = !iq.is_a?(Integer) || iq<1 || iq>5 ? 1 : iq
    end

    def to_s
      return @name if defined? @name and @name != nil
      case @iq
      when 1
        prefix = 'Greedy'
      when 2
        prefix = 'Normal'
      when 3
        prefix = 'Rational'
      when 4
        prefix = 'Smart'
      when 5
        prefix = 'Frenzied'
      end
      @name = prefix + ' Computer Player'
      @name
    end

    def move board
      c_player = self==board.player1 ? ConnectFour::Board::PLAYER1 : ConnectFour::Board::PLAYER2
      move = minmax board.board, @iq, c_player
      move[:move][0]
    end


    def minmax board, depth, player, alpha=-INF, beta=INF, max=true

      return { move: [], score: 0 } if ConnectFour::Board::draw? board

      if who = ConnectFour::Board::who_win?(board)
        return { move: [], score: who==player ? INF/2+depth : -(INF/2+depth) }
      end

      return { move: [], score: self.class::evalc(board, player)} if depth == 0

      possible_moves = Array.new
      ConnectFour::Board::WIDTH.times do |c|
        ConnectFour::Board::HEIGHT.times do |r|
          next unless board[r][c] == ConnectFour::Board::EMPTY_SLOT
          possible_moves << [r, c]
          break
        end
      end

      best_move = Array.new

      c_player = max ? player :
        (player==ConnectFour::Board::PLAYER1 ? ConnectFour::Board::PLAYER2 : ConnectFour::Board::PLAYER1)

      if max == true
        best_score = -INF
        possible_moves.each do |pos|
          tmp_board = board.map{|rr| rr.map{|cc| cc}}
          tmp_board[pos[0]][pos[1]] = c_player
          res = minmax tmp_board, depth-1, player, alpha, beta, false
          if res[:score] > best_score
            best_move = [pos[1]] + res[:move]
            best_score = res[:score]
          end
          alpha = best_score if best_score > alpha
          break if beta <= alpha
        end
      else
        best_score = INF
        possible_moves.each do |pos|
          tmp_board = board.map{|rr| rr.map{|cc| cc}}
          tmp_board[pos[0]][pos[1]] = c_player
          res = minmax tmp_board, depth-1, player, alpha, beta, true
          if res[:score] < best_score
            best_move = [pos[1]] + res[:move]
            best_score = res[:score]
          end
          beta = best_score if best_score < beta
          break if beta <= alpha
        end
      end
      { move: best_move, score: best_score }
    end

    # @param board [ConnectFour::Board.board] a copy of current board array
    # @param c_player [ConnectFour::Board::PLAYER1, ConnectFour::Board::PLAYER2] the currect player
    def self.evalc board, c_player
      o_player = c_player==ConnectFour::Board::PLAYER1 ?
        ConnectFour::Board::PLAYER2 : ConnectFour::Board::PLAYER1

      # Initialize the value of scores
      # [s0, s1, s2, s3, --s4--]
      # s0 for the case where all slots are empty in a 4-slot line
      # s1 for the case where c_player occupies one slot in a 4-slot line, the rest are empty
      # s2 for two slots occupied
      # s3 for three
      # s4 for four -- win, it should not appear
      c_scores = Array.new 4, 0 # for current player
      o_scores = Array.new 4, 0 # for opposite player

      # Initalize the weights
      # [w0, w1, w2, w3, --w4--]
      # w0 for s0, w1 for s1, w2 for s2, w3 for s3
      # w4 for s4, it should not appear
      weights = [0, 1, 4, 16]

      # Obtain all 4-slot lines on the board
      seg = Array.new
      left_revolved_board = Array.new
      right_revolved_board = Array.new
      ConnectFour::Board::HEIGHT.times do |r|
        (ConnectFour::Board::WIDTH-3).times do |c|
          seg << board[r][c..c+3]
        end
        left_revolved_board << ([nil] * r + board[r] + [nil] * (ConnectFour::Board::HEIGHT-1-r))
        right_revolved_board << ([nil] * (ConnectFour::Board::HEIGHT-1-r) + board[r] + [nil] * r)
      end
      revolved_board = left_revolved_board.transpose[3..-4] + right_revolved_board.transpose[3..-4]
      revolved_board.map(&:compact).each do |d|
        (d.length-3).times do |dd|
          seg << d[dd..dd+3]
        end
      end
      ConnectFour::Board::WIDTH.times do |c|
        (ConnectFour::Board::HEIGHT-3).times do |r|
          seg << board[r..r+3].map{|rr| rr[c]}
        end
      end

      # count scores
      seg.each do |s|
        unless s.include? o_player
          c_scores[s.count c_player] += 1
        else
          o_scores[s.count o_player] += 1 unless s.include? c_player
        end
      end

      # calculate the final score
      pos_score = c_scores.zip(weights).inject(0) {|sum, (s, w)| sum+s*w}
      neg_score = o_scores.zip(weights).inject(0) {|sum, (s, w)| sum+s*w}
      pos_score - neg_score

    end

  end
end
