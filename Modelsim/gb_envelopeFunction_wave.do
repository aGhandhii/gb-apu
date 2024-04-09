onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_envelopeFunction_tb/clk
add wave -noupdate /gb_envelopeFunction_tb/clk_vol_env
add wave -noupdate /gb_envelopeFunction_tb/start
add wave -noupdate /gb_envelopeFunction_tb/initial_volume
add wave -noupdate /gb_envelopeFunction_tb/envelope_increasing
add wave -noupdate /gb_envelopeFunction_tb/num_envelope_sweeps
add wave -noupdate /gb_envelopeFunction_tb/target_vol
add wave -noupdate /gb_envelopeFunction_tb/dut/enve_left
add wave -noupdate /gb_envelopeFunction_tb/dut/enve_enabled
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {236 ps} 0}
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
WaveRestoreZoom {0 ps} {1 ns}
