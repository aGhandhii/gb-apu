onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_customWaveChannel_tb/dut/reset
add wave -noupdate /gb_customWaveChannel_tb/dut/clk
add wave -noupdate /gb_customWaveChannel_tb/dut/start
add wave -noupdate /gb_customWaveChannel_tb/dut/start_posedge
add wave -noupdate -group Length /gb_customWaveChannel_tb/dut/clk_length_ctr
add wave -noupdate -group Length /gb_customWaveChannel_tb/dut/length
add wave -noupdate -group Length /gb_customWaveChannel_tb/dut/lengthFunction/length_left
add wave -noupdate -group Length /gb_customWaveChannel_tb/dut/single
add wave -noupdate /gb_customWaveChannel_tb/dut/volume
add wave -noupdate /gb_customWaveChannel_tb/dut/on
add wave -noupdate /gb_customWaveChannel_tb/dut/frequency
add wave -noupdate /gb_customWaveChannel_tb/dut/wave_data
add wave -noupdate /gb_customWaveChannel_tb/dut/wave_addr
add wave -noupdate /gb_customWaveChannel_tb/dut/level
add wave -noupdate /gb_customWaveChannel_tb/dut/enable
add wave -noupdate /gb_customWaveChannel_tb/dut/current_pointer
add wave -noupdate /gb_customWaveChannel_tb/dut/current_sample
add wave -noupdate /gb_customWaveChannel_tb/dut/divider
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1116 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {2174 ps}
