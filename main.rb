class Player
  attr_accessor :name, :position
  
  def initialize(name='o')
    @name = name
    @position = {x: 0, y: 0}
  end
  
  # def update_position board, die
    # p *board
    # p die
  # end
end


class Board
  attr_accessor :board, :players, :die

  def initialize(players=[])
    @players = players
    @board = Array.new(10) {Array.new(10, '.')}
    @board[0][0] = 'o'
    @board[9][0] = '#'
  end

  def players
    @players.each do |player|
      puts player.name
    end
  end

  def show_board
    @board.each do |row|
      row.each do |cell|
        print cell, sep="  "
      end
      puts
    end
  end

  def roll_die
    self.die = Random.new.rand(1..6)
  end

  def update_board player_position, die
    @board[player_position[:x]][player_position[:y]] = '.'
    if player_position[:y] + die >= 10
      player_position[:x] += 1
      if player_position[:x] % 2 == 1
        player_position[:y] = 10 - ((player_position[:y] + die) % 10)
      else
        player_position[:y] = (player_position[:y] + die) % 10
      end
    else
      player_position[:y] += die
      if player_position[:x] % 2 == 1
        player_position[:y] = 10 - player_position[:y]
      else
        player_position[:y] = player_position[:y]
      end
    end
    @board[player_position[:x]][player_position[:y]] = 'o'
  end
end


# create player
player1 = Player.new("sid_ant")
player2 = Player.new("var_sha256")
player3 = Player.new("shiro")
players = [player1, player2, player3]

# create board
game = Board.new(players)

print "Old pos: "
puts player1.position
game.show_board

die = game.roll_die
puts "Die: " + die.to_s

game.update_board player1.position, die

puts
print "New pos: "
puts player1.position
game.show_board
