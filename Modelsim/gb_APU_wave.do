onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_APU_tb/reset
add wave -noupdate -group Clocks /gb_APU_tb/clk
add wave -noupdate -group Clocks /gb_APU_tb/dut/clk_length_ctr
add wave -noupdate -group Clocks /gb_APU_tb/dut/clk_vol_env
add wave -noupdate -group Clocks /gb_APU_tb/dut/clk_sweep
add wave -noupdate -group {CPU IO} /gb_APU_tb/wren
add wave -noupdate -group {CPU IO} /gb_APU_tb/addr_i
add wave -noupdate -group {CPU IO} /gb_APU_tb/data_i
add wave -noupdate -group {CPU IO} /gb_APU_tb/data_o
add wave -noupdate /gb_APU_tb/left
add wave -noupdate /gb_APU_tb/right
add wave -noupdate /gb_APU_tb/dut/ch1
add wave -noupdate /gb_APU_tb/dut/ch2
add wave -noupdate /gb_APU_tb/dut/ch3
add wave -noupdate /gb_APU_tb/dut/ch4
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
