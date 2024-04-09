onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /gb_noiseChannel_tb/reset
add wave -noupdate /gb_noiseChannel_tb/clk
add wave -noupdate -group LengthFunction /gb_noiseChannel_tb/clk_length_ctr
add wave -noupdate -group LengthFunction /gb_noiseChannel_tb/length
add wave -noupdate -group LengthFunction /gb_noiseChannel_tb/dut/lengthFunction/length_left
add wave -noupdate -group LengthFunction /gb_noiseChannel_tb/single
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/clk_vol_env
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/initial_volume
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/envelope_increasing
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/num_envelope_sweeps
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/dut/envelopeFunction/enve_left
add wave -noupdate -group EnvelopeFunction /gb_noiseChannel_tb/dut/target_vol
add wave -noupdate /gb_noiseChannel_tb/shift_clock_freq
add wave -noupdate /gb_noiseChannel_tb/counter_width
add wave -noupdate /gb_noiseChannel_tb/freq_dividing_ratio
add wave -noupdate /gb_noiseChannel_tb/start
add wave -noupdate /gb_noiseChannel_tb/level
add wave -noupdate /gb_noiseChannel_tb/enable
add wave -noupdate /gb_noiseChannel_tb/dut/start_posedge
add wave -noupdate /gb_noiseChannel_tb/dut/polynomialDivisor
add wave -noupdate /gb_noiseChannel_tb/dut/frequencyTimer
add wave -noupdate /gb_noiseChannel_tb/dut/calcFrequencyTimer
add wave -noupdate /gb_noiseChannel_tb/dut/lfsr
add wave -noupdate /gb_noiseChannel_tb/dut/lfsr_next
add wave -noupdate /gb_noiseChannel_tb/dut/target_freq_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2798 ps} 0}
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
WaveRestoreZoom {0 ps} {5303 ps}
