onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_lengthFunction_tb/WIDTH
add wave -noupdate /gb_lengthFunction_tb/clk
add wave -noupdate /gb_lengthFunction_tb/reset
add wave -noupdate /gb_lengthFunction_tb/clk_length_ctr
add wave -noupdate /gb_lengthFunction_tb/start
add wave -noupdate /gb_lengthFunction_tb/single
add wave -noupdate /gb_lengthFunction_tb/length
add wave -noupdate /gb_lengthFunction_tb/enable
add wave -noupdate /gb_lengthFunction_tb/dut/length_left
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
