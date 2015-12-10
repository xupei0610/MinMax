# encoding: UTF-8

require 'tk'
require 'yaml'

require_relative 'Board'
require_relative 'Agent/HumanAgent'
require_relative 'Agent/RandCompAgent'
require_relative 'Agent/IntelCompAgent'

module ConnectFour
  module Application

class GUI

  WINDOW_SIZE = [640, 480]
  SQUARE_SIZE = [50, 50]
  GAME_SIZE = [ConnectFour::Board::WIDTH, ConnectFour::Board::HEIGHT]

  def initialize
    @player1 = nil
    @player2 = nil
    @board = nil

    # Load Language File
    lang_pack = YAML.load File.open('asset/lang/en.yml')
    @@lang = lang_pack['en']

    @@agents = Array.new
    @@agents << @@lang['agent']['human_agent']
    @@agents << @@lang['agent']['rand_comp_agent']
    @@agents << @@lang['agent']['intel_comp_agent_1']
    @@agents << @@lang['agent']['intel_comp_agent_2']
    @@agents << @@lang['agent']['intel_comp_agent_3']
    @@agents << @@lang['agent']['intel_comp_agent_4']
    @@agents << @@lang['agent']['intel_comp_agent_5']

    TkOption.add '*tearOff', 0
    Tk::Tile::Style.theme_use 'clam'

    @root = TkRoot.new do
      title @@lang['window']['caption']
      minsize WINDOW_SIZE[0], WINDOW_SIZE[1]
      maxsize WINDOW_SIZE[0], WINDOW_SIZE[1]
      resizable false, false
    end

    @root.menu menu_bar

    @@new_game_button = TkButton.new @root do
      relief 'groove'
      text @@lang['button']['new_game']
      place :x => 10, :y => WINDOW_SIZE[1]- 35
    end
    @@new_game_button.command Proc.new { new_game }

  end

  def menu_bar
    menu_bar = TkMenu.new
    file = TkMenu.new
    file.add :command, :label => @@lang['window']['menu']['new'], :command => Proc.new { new_game }
    file.add :separator
    file.add :command, :label => @@lang['window']['menu']['quit']
    help = TkMenu.new
    help.add :command, :label => @@lang['window']['menu']['help']
    help.add :separator
    help.add :command, :label => @@lang['window']['menu']['about']
    menu_bar.add :cascade, :menu => file, :label => @@lang['window']['menu']['file']
    menu_bar.add :cascade, :menu => help, :label => @@lang['window']['menu']['help']
    menu_bar
  end

  def new_game
    @@new_game_window.destroy if defined? @@new_game_window and @@new_game_window.is_a? TkToplevel
    @@new_game_window = TkToplevel.new @root, background: 'white' do
      title @@lang['window']['new_game']['caption']
      resizable false, false
      padx 100
      pady 50
    end
    player1_agent = TkVariable.new.set_string @@lang['agent']['human_agent']
    player2_agent = TkVariable.new.set_string @@lang['agent']['human_agent']
    Tk::Tile::Combobox.new @@new_game_window do
      textvariable player1_agent
      values @@agents
      pack
    end
    Tk::Tile::Label.new @@new_game_window, background:'white' do
      text @@lang['vs']
      pack :pady=>10
    end
    Tk::Tile::Combobox.new @@new_game_window do
      textvariable player2_agent
      values @@agents
      pack
    end
    bt = Tk::Tile::Button.new @@new_game_window do
      text @@lang['window']['new_game']['submit']
      pack :pady=>20
    end
    bt.command = Proc.new do
        @player1 = self.class::load_agent player1_agent.to_s
        @player2 = self.class::load_agent player2_agent.to_s
        @@new_game_window.destroy
        run_game
    end
  end

  def run_game
    if defined? @@canvas
      @@canvas.delete 'all'
    else
      @@canvas = TkCanvas.new @root, background:'white' do
        pack :fill => 'both', :expand => 'yes'
      end
    end

    # Board
    @@board_pos = [(WINDOW_SIZE[0] - SQUARE_SIZE[0]*GAME_SIZE[0])/2,
                 WINDOW_SIZE[1] - SQUARE_SIZE[1]*GAME_SIZE[1] - SQUARE_SIZE[1]]
    @@board_pos << @@board_pos[0] + SQUARE_SIZE[0]*GAME_SIZE[0]
    @@board_pos << @@board_pos[1] + SQUARE_SIZE[1]*GAME_SIZE[1]
    (GAME_SIZE[0]+1).times do |c|
      TkcLine.new @@canvas, @@board_pos[0]+c*SQUARE_SIZE[0], @@board_pos[1], @@board_pos[0]+c*SQUARE_SIZE[0], @@board_pos[3]
    end
    (GAME_SIZE[1]+1).times do |r|
      TkcLine.new @@canvas, @@board_pos[0], @@board_pos[1]+r*SQUARE_SIZE[1], @@board_pos[2], @@board_pos[1]+r*SQUARE_SIZE[1]
    end

    # Player1
    draw_checker @player1, 20, 20, 20+SQUARE_SIZE[0], 20+SQUARE_SIZE[1]
    TkcText.new @@canvas, 20, 30+SQUARE_SIZE[1], text: @player1.to_s, anchor: 'nw'

    # Player2
    draw_checker @player2, WINDOW_SIZE[0]-SQUARE_SIZE[0]-20, 20, WINDOW_SIZE[0]-20, 20+SQUARE_SIZE[1]
    TkcText.new @@canvas, WINDOW_SIZE[0]-20, 30+SQUARE_SIZE[1], text: @player2.to_s, anchor: 'ne'

    # show button
    @@new_game_button.raise

    # Lord Board
    @board = ConnectFour::Board.new @player1, @player2

    # Run Game
    turn_for @player1
  end

  def turn_for player
    next_player = player==@player1 ? @player2 : @player1
    if player.is_a? ConnectFour::CompAgent
      @root.after 125 do
        place @board, player.move(@board), player
        unless @board.game_status == ConnectFour::Board::GAMEOVER
          turn_for next_player
        end
      end
    else
      @@user_checker = nil
      @@last_user_checker_pos = nil
      mouse_x, mouse_y = TkWinfo::pointerxy @root
      draw_checker_for_human_player_motion player, mouse_x, mouse_y
      @@canvas.bind 'Motion', Proc.new { |x, y|
        draw_checker_for_human_player_motion player, x, y
      }, '%x %y'
      @@canvas.bind '1', Proc.new { |x, y|
        if mouse_on_board x, y
          input_handle = Proc.new { ((x-@@board_pos[0])/SQUARE_SIZE[0]).floor + 1 }
          if place @board, player.move(@board, input_handle), player
            @@canvas.bind_remove 'Motion'
            @@canvas.bind_remove '1'
            turn_for next_player unless @board.game_status == ConnectFour::Board::GAMEOVER
          end
        end
      }, '%x %y'
    end
  end

  def draw_checker player, x1, y1, x2, y2
    color = player==@player1 ? '#c40003' : 'white'
    TkcOval.new @@canvas, x1, y1, x2, y2,
      fill: color, outline:'black', width: 3
  end

  def draw_checker_for_human_player_motion player, mouse_x, mouse_y
    x, y = mouse_x, mouse_y
    if mouse_on_board x, y
      col = ((x-@@board_pos[0])/SQUARE_SIZE[0]).floor
      unless col == @@last_user_checker_pos
        x1 = col*SQUARE_SIZE[0] + @@board_pos[0]
        x2 = x1+SQUARE_SIZE[0]
        y1, y2 = @@board_pos[1] - SQUARE_SIZE[1], @@board_pos[1]
        unless @@user_checker == nil
          @@canvas.delete @@user_checker
          @@user_checker = nil
          @@last_user_checker_pos = nil
        end
        @@user_checker = draw_checker player, x1+3, y1+3, x2-3, y2-3
        @@last_user_checker_pos = col
      end
    else
      unless @@user_checker == nil
        @@canvas.delete @@user_checker
        @@last_user_checker_pos = nil
        @@user_checker = nil
      end
    end
  end

  def mouse_on_board x, y
    x > @@board_pos[0] and x < @@board_pos[2] and y > @@board_pos[1] and y < @@board_pos[3]
  end

  def place board, move, player
    res = @board.place move do |flag|
      case flag
        when ConnectFour::Board::WIN
          # Draw Promption for Win
          if player==@player1
            TkcText.new @@canvas, 80+SQUARE_SIZE[0], 50, text: @@lang['win'], anchor: 'nw',
              font: TkFont.new('size'=>20,'weight'=>'bold')
          else
            TkcText.new @@canvas, WINDOW_SIZE[0]-80-SQUARE_SIZE[0], 50, text: @@lang['win'], anchor: 'ne',
              font: TkFont.new('size'=>20,'weight'=>'bold')
          end
        when ConnectFour::Board::DRAW
          # Draw Promption for Draw
          TkcText.new @@canvas, WINDOW_SIZE[0]/2, 50, text: @@lang['draw'], anchor: 'center',
            font: TkFont.new('size'=>20,'weight'=>'bold')
        when true
          # Draw move
          r = nil
          (GAME_SIZE[1]-1).downto(0) do |rr|
            unless @board.board[rr][move] == ConnectFour::Board::EMPTY_SLOT
              r = rr+1
              break
            end
          end
          if defined? @@user_checker and @@user_checker != nil
            @@canvas.delete @@user_checker
            @@user_checker = nil
            @@last_user_checker_pos = nil
          end
          x1, y1 = @@board_pos[0]+move*SQUARE_SIZE[0], @@board_pos[1]+(GAME_SIZE[1]-r)*SQUARE_SIZE[1]
          draw_checker player, x1+3, y1+3, x1+SQUARE_SIZE[0]-3, y1+SQUARE_SIZE[1]-3
      end
    end
    res
  end


  def play
    Tk.mainloop
  end

  def self.load_agent agent_name
    case agent_name
    when @@lang['agent']['human_agent']
      ag = ConnectFour::HumanAgent.new
    when @@lang['agent']['rand_comp_agent']
      ag = ConnectFour::RandCompAgent.new
    when @@lang['agent']['intel_comp_agent_1']
      ag = ConnectFour::IntelCompAgent.new 1
    when @@lang['agent']['intel_comp_agent_2']
      ag = ConnectFour::IntelCompAgent.new 2
    when @@lang['agent']['intel_comp_agent_3']
      ag = ConnectFour::IntelCompAgent.new 3
    when @@lang['agent']['intel_comp_agent_4']
      ag = ConnectFour::IntelCompAgent.new 4
    when @@lang['agent']['intel_comp_agent_5']
      ag = ConnectFour::IntelCompAgent.new 5
    else
      return nil
    end
    ag.name = agent_name
    ag
  end

end

  end
end
