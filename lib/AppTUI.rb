# encoding: UTF-8
require_relative 'Board'
require_relative 'Agent/HumanAgent'
require_relative 'Agent/RandCompAgent'
require_relative 'Agent/IntelCompAgent'

module ConnectFour
  module Application

class TUI

  EMPTY_SIGN = '·'
  PLAYER1_SIGN = '◎'
  PLAYER2_SIGN = '◎'

  def initialize
    @player1, @player2 = self.class::configure
    @board = ConnectFour::Board.new @player1, @player2
    @input_handle = Proc.new do
      inp = gets.chomp
      if inp == 'q' or inp == 'Q'
        exit
      end
      inp.to_i
    end
  end

  def play
    draw_board
    i = 0
    until @board.game_status ==  ConnectFour::Board::GAMEOVER
      i += 1
      player = i%2==1 ? @player1 : @player2
      while true
        if player.is_a? ConnectFour::CompAgent
          sleep 0.5 if player.is_a? ConnectFour::IntelCompAgent and player.iq < 4
          break unless place(player, player.move(@board)) == false
        else
          print 'Turn for ', player_name_of(player), "\nMake Your Choice: "
          break unless place(player, player.move(@board, @input_handle)) == false
        end
      end
      draw_board
    end
  end

  def player_name_of whom
    whom==@player1 ?
      "#{whom.to_s} #{player_sign_of whom} (Player 1)" :
      "#{whom.to_s} #{player_sign_of whom} (Player 2)"
  end

  def player_sign_of whom
    whom==@player1 ?
      "\033[91m" + PLAYER1_SIGN + "\033[0m" :
      "\033[92m" + PLAYER2_SIGN + "\033[0m"
  end

  def place who, where
    name = player_name_of who
    position = case where
      when 0
        '1st'
      when 1
        '2nd'
      else
        (where+1).to_s + 'th'
      end
    puts ''
    res = @board.place where do |x|
      case x
      when ConnectFour::Board::WIN
        puts name + "\n\tWIN!"
      when ConnectFour::Board::DRAW
        puts "\n\n\tDRAW!"
      when false
        puts name + "\n\ttries to place a piece at the #{position} column.\nBut, sorry, there is no space at that column."
      else
        puts name + "\n\tplaces a piece at the #{position} column."
      end
    end
    puts ''
    res
  end

  def draw_board
    puts "\t" + (1..@board.class::WIDTH).to_a.join(' ')
    puts "\t" + '↓ ' * @board.class::WIDTH
    (@board.class::HEIGHT-1).downto(0) do |r|
      output = @board.board[r].join ' '
      output.gsub! @board.class::EMPTY_SLOT.to_s, EMPTY_SIGN
      output.gsub! @board.class::PLAYER1.to_s, player_sign_of(@player1)
      output.gsub! @board.class::PLAYER2.to_s, player_sign_of(@player2)
      puts "\t" + output
    end
  end

  def self.configure
    choose_level_for = Proc.new do |whom|
      while true
        puts ''
        puts 'Please Choose A Level for ' + whom
        puts '0. Unpredictable'
        puts '1. Greedy'
        puts '2. Normal'
        puts '3. Rational'
        puts '4. Smart'
        puts '5. Frenzied'
        iq = gets.chomp.to_i
        break if (0..5).include? iq
      end
      iq
    end

    while true
      puts ''
      puts 'Please Choose Game Mode'
      puts '1. Computer v.s. Computer'
      puts '2. Human v.s. Computer'
      mode = gets.chomp.to_i
      break if mode == 1 or mode == 2
    end

    if mode == 1
      player1 = (iq1 = choose_level_for.call 'the 1st Computer Player')==0 ?
        ConnectFour::RandCompAgent.new : ConnectFour::IntelCompAgent.new(iq1)
      player2 = (iq2 = choose_level_for.call 'the 2nd Computer Player')==0 ?
        ConnectFour::RandCompAgent.new : ConnectFour::IntelCompAgent.new(iq2)
    else
      while true
        puts ''
        puts 'Who Should Move Firstly?'
        puts '1. Computer'
        puts '2. Human'
        first = gets.chomp.to_i
        break if first == 1 or first == 2
      end
      iq = choose_level_for.call 'Computer Player'
      if first == 1
        player1 = iq==0? ConnectFour::RandCompAgent.new : ConnectFour::IntelCompAgent.new(iq)
        player2 = ConnectFour::HumanAgent.new
      else
        player2 = iq==0? ConnectFour::RandCompAgent.new : ConnectFour::IntelCompAgent.new(iq)
        player1 = ConnectFour::HumanAgent.new
      end
    end
    return player1, player2

  end

end

  end
end
