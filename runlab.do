# Create work library
vlib work

# Compile Code
vlog "./src/*.sv"
vlog "./test/gb_APU_tb.sv"

# Start the Simulator
vsim -voptargs="+acc" -t 1ps -lib work gb_APU_tb

# Source the wave file
do ./Modelsim/gb_APU_wave.do

# Set window types
view wave
view structure
view signals

# Run the simulation
run -all
