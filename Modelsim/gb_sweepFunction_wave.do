onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_sweepFunction_tb/clk
add wave -noupdate /gb_sweepFunction_tb/clk_sweep
add wave -noupdate /gb_sweepFunction_tb/trigger
add wave -noupdate /gb_sweepFunction_tb/sweep_pace
add wave -noupdate /gb_sweepFunction_tb/sweep_decreasing
add wave -noupdate /gb_sweepFunction_tb/num_sweep_shifts
add wave -noupdate /gb_sweepFunction_tb/frequency
add wave -noupdate /gb_sweepFunction_tb/overflow
add wave -noupdate /gb_sweepFunction_tb/shadow_frequency
add wave -noupdate /gb_sweepFunction_tb/dut/sweep_enabled
add wave -noupdate /gb_sweepFunction_tb/dut/sweep_timer
add wave -noupdate /gb_sweepFunction_tb/dut/new_frequency
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 2
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
