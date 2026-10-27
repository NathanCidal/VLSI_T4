onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ps2_driver_tb/clock_in
add wave -noupdate /ps2_driver_tb/reset_in
add wave -noupdate /ps2_driver_tb/clock_ps2
add wave -noupdate /ps2_driver_tb/data_ps2
add wave -noupdate /ps2_driver_tb/data_p
add wave -noupdate /ps2_driver_tb/data_p_en
add wave -noupdate /ps2_driver_tb/en_count
add wave -noupdate /ps2_driver_tb/en_width
add wave -noupdate /ps2_driver_tb/last_data
add wave -noupdate /ps2_driver_tb/errors
add wave -noupdate /ps2_driver_tb/total
add wave -noupdate /ps2_driver_tb/n_before
add wave -noupdate -divider DUT
add wave -noupdate /ps2_driver_tb/dut/slow_clk
add wave -noupdate /ps2_driver_tb/dut/reset_in
add wave -noupdate /ps2_driver_tb/dut/data
add wave -noupdate /ps2_driver_tb/dut/data_ps2_q
add wave -noupdate /ps2_driver_tb/dut/data_p_en
add wave -noupdate /ps2_driver_tb/dut/data_p
add wave -noupdate /ps2_driver_tb/dut/parity_bit
add wave -noupdate /ps2_driver_tb/dut/expected_parity
add wave -noupdate /ps2_driver_tb/dut/fall_edge_slow
add wave -noupdate /ps2_driver_tb/dut/rise_edge_slow
add wave -noupdate /ps2_driver_tb/dut/current_state
add wave -noupdate /ps2_driver_tb/dut/next_state
add wave -noupdate /ps2_driver_tb/dut/calibrate
add wave -noupdate /ps2_driver_tb/dut/sysreset
add wave -noupdate /ps2_driver_tb/dut/reset_fsm
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {505757152 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {505611541 ps} {506125250 ps}
