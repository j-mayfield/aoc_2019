# --- Day 15: Oxygen System ---
# Out here in deep space, many things can go wrong. Fortunately, many of those things have indicator lights. Unfortunately, one of those lights is lit: the oxygen system for part of the ship has failed!
#
# According to the readouts, the oxygen system must have failed days ago after a rupture in oxygen tank two; that section of the ship was automatically sealed once oxygen levels went dangerously low. A single remotely-operated repair droid is your only option for fixing the oxygen system.
#
# The Elves' care package included an Intcode program (your puzzle input) that you can use to remotely control the repair droid. By running that program, you can direct the repair droid to the oxygen system and fix the problem.
#
# The remote control program executes the following steps in a loop forever:
#
# Accept a movement command via an input instruction.
# Send the movement command to the repair droid.
# Wait for the repair droid to finish the movement operation.
# Report on the status of the repair droid via an output instruction.
# Only four movement commands are understood: north (1), south (2), west (3), and east (4). Any other command is invalid. The movements differ in direction, but not in distance: in a long enough east-west hallway, a series of commands like 4,4,4,4,3,3,3,3 would leave the repair droid back where it started.
#
# The repair droid can reply with any of the following status codes:
#
# 0: The repair droid hit a wall. Its position has not changed.
# 1: The repair droid has moved one step in the requested direction.
# 2: The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.
# You don't know anything about the area around the repair droid, but you can figure it out by watching the status codes.
#
# For example, we can draw the area using D for the droid, # for walls, . for locations the droid can traverse, and empty space for unexplored locations. Then, the initial state looks like this:
#
#
#
#    D
#
#
# To make the droid go north, send it 1. If it replies with 0, you know that location is a wall and that the droid didn't move:
#
#
#    #
#    D
#
#
# To move east, send 4; a reply of 1 means the movement was successful:
#
#
#    #
#    .D
#
#
# Then, perhaps attempts to move north (1), south (2), and east (4) are all met with replies of 0:
#
#
#    ##
#    .D#
#     #
#
# Now, you know the repair droid is in a dead end. Backtrack with 3 (which you already know will get a reply of 1 because you already know that location is open):
#
#
#    ##
#    D.#
#     #
#
# Then, perhaps west (3) gets a reply of 0, south (2) gets a reply of 1, south again (2) gets a reply of 0, and then west (3) gets a reply of 2:
#
#
#    ##
#   #..#
#   D.#
#    #
# Now, because of the reply of 2, you know you've found the oxygen system! In this example, it was only 2 moves away from the repair droid's starting position.
#
# What is the fewest number of movement commands required to move the repair droid from its starting position to the location of the oxygen system?

require_relative 'int_code_processor'
require 'tree'

puts 'day_15 part_1'

# ---
class OxygenTankFinder
  def initialize(input)
    @input     = input
    @root_node = Tree::TreeNode.new('START', [])
    @index     = 0
    @output    = []
  end

  def remove_childless_node(node)
    return if node.has_children? || node.is_root?
    parent = node.parent
    parent.remove!(node)
    remove_childless_node(parent)
  end

  def test_new_direction(existing_path, new_direction)
    robot = IntCodeProcessor.new(@input, interrupt: true, quiet: true)
    existing_path.each { |i| robot.run_intcode(i) }
    robot.run_intcode(new_direction)
  end

  def find_it
    @root_node.each_leaf do |node|
      puts "node = #{node} // node.content.count = #{node.content.count} // @output.uniq = #{@output.uniq}" if (@index % 1000).zero?
      existing_path = node.is_root? ? [] : node.content
      1.upto(4) do |d|
        # robot = IntCodeProcessor.new(@input, interrupt: true, quiet: true)
        # parent_content.each { |i| robot.run_intcode(i) }
        # output = robot.run_intcode(d)
        output = test_new_direction(existing_path, d)
        @output << output
        if output.eql?(2)
          puts "found '2' after #{node.content.count + 1} steps\nsteps: #{node.content + [d]}"
          exit
        end
        node.add(Tree::TreeNode.new((@index += 1).to_s, existing_path + [d])) unless output.eql?(0)
      end
      remove_childless_node(node)
    end
  end
end

finder = OxygenTankFinder.new(File.read('day_15_input.txt'))
loop { finder.find_it }
