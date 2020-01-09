# Convert comma-separated input to array and process as IntCode
class IntCodeProcessor
  def initialize(input = '', **args)
    @pointer       = -1
    @input         = input_array(input)
    @output        = []
    @relative_base = 0
    @interrupt     = args[:interrupt].nil? ? false : args[:interrupt]
    @persist_input = args[:persist_input].nil? ? false : args[:persist_input]
    @quiet         = args[:quiet].nil? ? false : args[:quiet]
  end

  def run_intcode(*integer_input)
    loop do
      command = value_at_incremented_pointer.to_s.rjust(5, '0').chars
      opcode  = "#{command[3]}#{command[4]}".to_i
      break if opcode.eql?(99)
      run_op(opcode, command, integer_input)
      return @output.last if opcode.eql?(4) && @interrupt
    end
    puts 'HALT' unless @quiet
    @output
  end

  private

  def input_array(input)
    input.split(',').map(&:to_i)
  end

  def value_at_pointer(p)
    check_available_memory(p)
    @input[p]
  end

  def check_available_memory(p)
    loop do
      break if @input.count > p + 1
      @input.push(0)
    end
  end

  def value_at_incremented_pointer
    check_available_memory(@pointer += 1)
    value_at_pointer(@pointer)
  end

  def write_position(mode)
    pointer = mode.eql?(2) ? @relative_base + value_at_incremented_pointer : value_at_incremented_pointer
    check_available_memory(pointer)
    pointer
  end

  def next_value(mode)
    send("next_value_mode_#{mode}")
  end

  # Position Mode
  def next_value_mode_0
    value_at_pointer(value_at_incremented_pointer)
  end

  # Immediate Mode
  def next_value_mode_1
    value_at_incremented_pointer
  end

  # Relative Mode
  def next_value_mode_2
    value_at_pointer(@relative_base + value_at_incremented_pointer)
  end

  def run_op(opcode, command, integer_input)
    send("op_#{opcode}", *[param_mode_p1: command[2].to_i, param_mode_p2: command[1].to_i, param_mode_p3: command[0].to_i, integer_input: integer_input])
  end

  # Addition
  def op_1(**args)
    p1         = next_value(args[:param_mode_p1])
    p2         = next_value(args[:param_mode_p2])
    p3         = write_position(args[:param_mode_p3])
    @input[p3] = p1 + p2
  end

  # Multiplication
  def op_2(**args)
    p1         = next_value(args[:param_mode_p1])
    p2         = next_value(args[:param_mode_p2])
    p3         = write_position(args[:param_mode_p3])
    @input[p3] = p1 * p2
  end

  # Read Input
  def op_3(**args)
    p         = write_position(args[:param_mode_p1])
    v         = @persist_input ? args[:integer_input].first : args[:integer_input].shift
    @input[p] = v
  end

  # Print Output
  def op_4(**args)
    @output << next_value(args[:param_mode_p1])
    puts "[op_4] output: #{@output.last}" unless @quiet
  end

  # Jump if True
  def op_5(**args)
    p1       = next_value(args[:param_mode_p1])
    p2       = next_value(args[:param_mode_p2])
    @pointer = p2 - 1 unless p1.zero?
  end

  # Jump if False
  def op_6(**args)
    p1       = next_value(args[:param_mode_p1])
    p2       = next_value(args[:param_mode_p2])
    @pointer = p2 - 1 if p1.zero?
  end

  # Less Than
  def op_7(**args)
    p1         = next_value(args[:param_mode_p1])
    p2         = next_value(args[:param_mode_p2])
    p3         = write_position(args[:param_mode_p3])
    @input[p3] = p1 < p2 ? 1 : 0
  end

  # Equals
  def op_8(**args)
    p1         = next_value(args[:param_mode_p1])
    p2         = next_value(args[:param_mode_p2])
    p3         = write_position(args[:param_mode_p3])
    @input[p3] = p1.eql?(p2) ? 1 : 0
  end

  # Adjust Relative Base
  def op_9(**args)
    @relative_base += next_value(args[:param_mode_p1])
  end
end
