# Create work library
vlib work

# Compile Code
vlog "./src/*.sv"
vlog "./test/gb_pulseChannel_tb.sv"

# Start the Simulator
vsim -voptargs="+acc" -t 1ps -lib work gb_pulseChannel_tb

# Source the wave file
do ./Modelsim/gb_pulseChannel_wave.do

# Set window types
view wave
view structure
view signals

# Run the simulation
run -all
