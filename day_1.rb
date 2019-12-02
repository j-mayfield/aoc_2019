input = %w(
104489
69854
93424
103763
119636
130562
121744
84851
143661
94519
116576
148771
74038
131735
95594
125198
92217
84471
53518
97787
55422
137807
78806
74665
103930
121642
123008
104598
97383
129359
85372
88930
106944
118404
126095
67230
116697
85950
148291
123171
82736
52753
134746
53238
74952
105933
104613
115283
80320
139152
76455
66729
81209
130176
116843
67292
74262
131694
92817
51540
58957
143342
76896
129631
77148
129784
115307
96214
110538
51492
124376
78161
59821
58184
132524
130714
112653
137988
112269
62214
115989
123073
119711
82258
67695
81023
70012
93438
131749
103652
63557
88224
117414
75579
146422
139852
85116
124902
143167
147781
)

# --- Day 1: The Tyranny of the Rocket Equation ---
# Santa has become stranded at the edge of the Solar System while delivering presents to other planets! To accurately calculate his position in space, safely align his warp drive, and return to Earth in time to save Christmas, he needs you to bring him measurements from fifty stars.
#
# Collect stars by solving puzzles. Two puzzles will be made available on each day in the Advent calendar; the second puzzle is unlocked when you complete the first. Each puzzle grants one star. Good luck!
#
# The Elves quickly load you into a spacecraft and prepare to launch.
#
# At the first Go / No Go poll, every Elf is Go until the Fuel Counter-Upper. They haven't determined the amount of fuel required yet.
#
# Fuel required to launch a given module is based on its mass. Specifically, to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
#
# For example:
#
# For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
# For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
# For a mass of 1969, the fuel required is 654.
# For a mass of 100756, the fuel required is 33583.
# The Fuel Counter-Upper needs to know the total fuel requirement. To find it, individually calculate the fuel needed for the mass of each module (your puzzle input), then add together all the fuel values.
#
# What is the sum of the fuel requirements for all of the modules on your spacecraft?

puts 'day_1 part_1'

fuel_per_module = input.map { |m| (m.to_i / 3) - 2 }
puts "fuel_required = #{fuel_per_module.inject(:+)}"

# --- Part Two ---
# During the second Go / No Go poll, the Elf in charge of the Rocket Equation Double-Checker stops the launch sequence. Apparently, you forgot to include additional fuel for the fuel you just added.
#
# Fuel itself requires fuel just like a module - take its mass, divide by three, round down, and subtract 2. However, that fuel also requires fuel, and that fuel requires fuel, and so on. Any mass that would require negative fuel should instead be treated as if it requires zero fuel; the remaining mass, if any, is instead handled by wishing really hard, which has no mass and is outside the scope of this calculation.
#
# So, for each module mass, calculate its fuel and add it to the total. Then, treat the fuel amount you just calculated as the input mass and repeat the process, continuing until a fuel requirement is zero or negative. For example:
#
# A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
# At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
# The fuel required by a module of mass 100756 and its fuel is: 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
# What is the sum of the fuel requirements for all of the modules on your spacecraft when also taking into account the mass of the added fuel? (Calculate the fuel requirements for each module separately, then add them all up at the end.)

puts 'day_1 part_2'

def total_fuel(f)
  additional_fuel = [((f / 3) - 2), 0].max
  return f if additional_fuel.zero?
  f + total_fuel(additional_fuel)
end

puts "total_fuel = #{fuel_per_module.map { |f| total_fuel(f) }.inject(:+)}"
