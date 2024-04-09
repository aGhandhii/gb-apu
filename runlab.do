# Create work library
vlib work

# Compile Code
vlog "./src/*.sv"
vlog "./test/gb_noiseChannel_tb.sv"

# Start the Simulator
vsim -voptargs="+acc" -t 1ps -lib work gb_noiseChannel_tb

# Source the wave file
do ./Modelsim/gb_noiseChannel_wave.do

# Set window types
view wave
view structure
view signals

# Run the simulation
run -all
