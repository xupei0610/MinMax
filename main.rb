#
# This is the main file of Connect-Four
#
# @author Pei Xu, 5186611
# @version 1.0.1
# @license MIT

require_relative 'lib/AppTUI'
require_relative 'lib/AppGUI'

BEGIN {
  puts ''
  puts '================== Welcome =================='
  puts '==                                         =='
  puts '==              Four in a Row              =='
  puts '==                                         =='
  puts '==                                         =='
  puts '========== Author: Pei Xu, 5186611 =========='
  puts '==                                         =='
}

END {
  puts ''
  puts '============================================='
  puts '==                                         =='
  puts '==                Good Bye                 =='
  puts '==                                         =='
  puts '==                                         =='
  puts '========== Author: Pei Xu, 5186611 =========='
  puts '==                                         =='
  puts ''
}

if __FILE__ == $0

  while true
    puts ''
    puts 'Please Choose UI Mode'
    puts '1. TUI'
    puts '2. GUI (Tk)'
    ui = gets.chomp.to_i
    break if ui == 1 or ui == 2
  end

  app = ui==2 ?
    ConnectFour::Application::GUI.new : ConnectFour::Application::TUI.new

  app.play

end
