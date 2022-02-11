require 'curses'
require 'byebug'

# Curses.init_screen
# Curses.curs_set(0)

class Player
  attr_accessor :name, :position, :die
  
  def initialize(name='O')
    @name = name
    @position = {x: 0, y: 0}
    @die = Random.new
  end

  def roll_die
    self.die.rand(1..6)
  end

  def begin?
    !! (roll_die == 1)
  end

  def won?
    !! (@position[:x] == 9 and @position[:y] == 0)
  end
end


class Board
  attr_accessor :board, :players, :die, :snakes, :ladders
  @@rand_obj = Random.new

  def initialize(players=[])
    @players = players
    @board = create_board
  end

  def create_board
    board = Array.new(10) {Array.new(10)}
    
    @snakes_and_ladders = {}
    bottoms = (2..89).to_a.sample 20
    occupied = Array.new(100, false)

    bottoms.each do |bottom|
      occupied[bottom-1] = true
      begin
        top = @@rand_obj.rand((bottom+1)..99)
        # byebug
      end while occupied[top-1] or (top)/10 == bottom/10
      occupied[top-1] = true
      @snakes_and_ladders[bottom] = top
    end

    @ladders = {}
    @snakes = {}
    
    @snakes_and_ladders.each do |key, value|
      if @ladders.count == 10
        break
      end
      @ladders[key] = value
    end

    @snakes_and_ladders.reverse_each do |key, value|
      if @snakes.count == 10
        break
      end
      @snakes[value] = key
    end

    for i in (0..9)
      for j in (0..9)
        board_no = (i * 10) + (j + 1)
        
        if @snakes.key?(board_no)
          board[i][j] = 'ST'
          top = @snakes[board_no]
          board[top/10][top%10] = 'SB'
        elsif @ladders.key?(board_no)
          board[i][j] = 'LB'
          top = @ladders[board_no]
          board[top/10][top%10] = 'LT'
          # print top.to_s + " " + board[top/10][top%10]
          # puts
        else
          if i % 2 == 1
            board[i][j] = (i * 10) + (10 - j)
          else
            board[i][j] = board_no
          end
        end
      end
    end

    board[0][0] = 'S'
    board[9][0] = 'E'

    
    p "Ladders", ladders
    p "Snakes", snakes
    board
  end

  def players
    @players.each do |player|
      puts player.name
    end
  end

  def show_board player_position, die
    for i in (0..9)
      for j in (0..9)
        # print @board[9-i][j].to_s + "    "
        Curses.setpos(i, j*4)
        Curses.addstr(@board[9-i][j].to_s)
      end
      puts
    end
  end

  def update_board player_position, die
    old_x = player_position[:x]
    old_y = player_position[:y]
    old_position_no = (old_x * 10) + (old_y + 1)

    if player_position[:x] % 2 == 0
      if player_position[:y] + die >= 10
        player_position[:x] += 1
        player_position[:y] = 9 - ((player_position[:y] + die) % 10)
      else
        player_position[:y] = player_position[:y] + die
      end
    else
      if player_position[:y] - die < 0
        if player_position[:x] == 9
          @board[player_position[:x]][player_position[:y]] = '  '
          return player_position
        end
        player_position[:x] += 1
        player_position[:y] = 9 - ((player_position[:y] - die) % 10)
      else
        player_position[:y] = player_position[:y] - die
      end
      old_position_no = (old_x * 10) + (10 - old_y)
    end

    @board[old_x][old_y] = old_position_no
    new_position_no = (player_position[:x] * 10) + (player_position[:y] + 1)
    if @snakes_and_ladders.key?(new_position_no)
      if @board[player_position[:x]][player_position[:y]] == 'LB'
        player_position[:x] = @snakes_and_ladders[new_position_no]/10
        player_position[:y] = @snakes_and_ladders[new_position_no]%10
      elsif @board[player_position[:x]][player_position[:y]] == 'ST'
        player_position[:x] = @snakes_and_ladders[new_position_no]/10
        player_position[:y] = @snakes_and_ladders[new_position_no]%10
      end
    end

    @board[player_position[:x]][player_position[:y]] = '  '
  end
end


# create player
player1 = Player.new("sid_ant")
players = [player1]

# create board
game = Board.new(players)

Curses.setpos(0, 0)
Curses.addstr("#{player1.name.capitalize}'s turn: [Roll die]")
Curses.getch

# die value 1 begins the game
while !player1.begin?
  Curses.addstr("\r#{player1.name.capitalize}'s turn: [Die value not 1]") 
  Curses.getch
end
Curses.clear

game.show_board player1.position, player1.die
# Curses.getch

while !player1.won?
  die = player1.roll_die
  game.update_board player1.position, die
  game.show_board player1.position, die

  Curses.setpos(10, 0)
  Curses.addstr("Die: #{die} Postion: #{player1.position}")
  Curses.getch
end

Curses.addstr("\nGame won")
Curses.getch
