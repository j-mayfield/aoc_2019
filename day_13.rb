# --- Day 13: Care Package ---
# As you ponder the solitude of space and the ever-increasing three-hour roundtrip for messages between you and Earth, you notice that the Space Mail Indicator Light is blinking. To help keep you sane, the Elves have sent you a care package.
#
# It's a new game for the ship's arcade cabinet! Unfortunately, the arcade is all the way on the other end of the ship. Surely, it won't be hard to build your own - the care package even comes with schematics.
#
# The arcade cabinet runs Intcode software like the game the Elves sent (your puzzle input). It has a primitive screen capable of drawing square tiles on a grid. The software draws tiles to the screen with output instructions: every three output instructions specify the x position (distance from the left), y position (distance from the top), and tile id. The tile id is interpreted as follows:
#
# 0 is an empty tile. No game object appears in this tile.
# 1 is a wall tile. Walls are indestructible barriers.
# 2 is a block tile. Blocks can be broken by the ball.
# 3 is a horizontal paddle tile. The paddle is indestructible.
# 4 is a ball tile. The ball moves diagonally and bounces off objects.
# For example, a sequence of output values like 1,2,3,6,5,4 would draw a horizontal paddle tile (1 tile from the left and 2 tiles from the top) and a ball tile (6 tiles from the left and 5 tiles from the top).
#
# Start the game. How many block tiles are on the screen when the game exits?

require_relative 'int_code_processor'

def number_of_blocks(intcode_output)
  h = {}
  intcode_output.each_slice(3) { |slice| h["#{slice[0]},#{slice[1]}".to_sym] = slice[2] }
  h.each_value.count { |v| v.eql?(2) }
end

puts 'day_13 part_1'
output = IntCodeProcessor.new(File.read('day_13_input.txt')).run_intcode
puts output.to_s
puts number_of_blocks(output)

# --- Part Two ---
# The game didn't run because you didn't put in any quarters. Unfortunately, you did not bring any quarters. Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.
#
# The arcade cabinet has a joystick that can move left and right. The software reads the position of the joystick with input instructions:
#
# If the joystick is in the neutral position, provide 0.
# If the joystick is tilted to the left, provide -1.
# If the joystick is tilted to the right, provide 1.
# The arcade cabinet also has a segment display capable of showing a single number that represents the player's current score. When three output instructions specify X=-1, Y=0, the third output instruction is not a tile; the value instead specifies the new score to show in the segment display. For example, a sequence of output values like -1,0,12345 would show 12345 as the player's current score.
#
# Beat the game by breaking all the blocks. What is your score after the last block is broken?

puts 'day_13 part_2'
intcode  = IntCodeProcessor.new(File.read('day_13_input.txt').gsub(/^[0-9]+,/, '2,'), interrupt: true, persist_input: true)
score    = 0
h        = {}
ball_x   = 0
paddle_x = 0
loop do
  input = ball_x <=> paddle_x
  x_pos = intcode.run_intcode(input)
  y_pos = intcode.run_intcode(input)
  tile  = intcode.run_intcode(input)
  break unless [x_pos, y_pos, tile].map { |i| i.is_a?(Fixnum) }.inject(:&)
  if x_pos.eql?(-1) && y_pos.eql?(0)
    score = tile
  else
    h["#{x_pos},#{y_pos}".to_sym] = tile
    paddle_x                      = x_pos if tile.eql?(3)
    ball_x                        = x_pos if tile.eql?(4)
  end
  blocks = h.each_value.count { |v| v.eql?(2) }
  puts "there are #{blocks} blocks left and the score is #{score}"
end

# Your puzzle answer was 10800.
#
# Both parts of this puzzle are complete! They provide two gold stars: **
