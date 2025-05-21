onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold /tb_control/ena
add wave -noupdate -color Gold /tb_control/clk
add wave -noupdate -color Gold /tb_control/Control_L0/rst
add wave -noupdate -color Gold /tb_control/Control_L0/done_FSM
add wave -noupdate /tb_control/Control_L0/current_state
add wave -noupdate /tb_control/Control_L0/next_state
add wave -noupdate -color Cyan /tb_control/add_i
add wave -noupdate -color Cyan /tb_control/sub_i
add wave -noupdate -color Cyan /tb_control/and_i
add wave -noupdate -color Cyan /tb_control/or_i
add wave -noupdate -color Cyan /tb_control/xor_i
add wave -noupdate -color Cyan /tb_control/jmp_i
add wave -noupdate -color Cyan /tb_control/jc_i
add wave -noupdate -color Cyan /tb_control/jnc_i
add wave -noupdate -color Cyan /tb_control/mov_i
add wave -noupdate -color Cyan /tb_control/ld_i
add wave -noupdate -color Cyan /tb_control/st_i
add wave -noupdate -color Cyan /tb_control/done_i
add wave -noupdate -color Cyan /tb_control/Nflag_i
add wave -noupdate -color Cyan /tb_control/Zflag_i
add wave -noupdate -color Cyan /tb_control/Cflag_i
add wave -noupdate /tb_control/Control_L0/C_last_instruction
add wave -noupdate -color Pink /tb_control/DTCM_wr_o
add wave -noupdate -color Pink /tb_control/DTCM_addr_out_o
add wave -noupdate -color Pink /tb_control/DTCM_addr_in_o
add wave -noupdate -color Pink /tb_control/DTCM_out_o
add wave -noupdate -color Pink /tb_control/Ain_o
add wave -noupdate -color Pink /tb_control/IRin_o
add wave -noupdate -color Pink /tb_control/RFin_o
add wave -noupdate -color Pink /tb_control/Control_L0/RFaddr_wr
add wave -noupdate -color Pink /tb_control/Control_L0/RFaddr_rd
add wave -noupdate -color Pink /tb_control/RFout_o
add wave -noupdate -color Pink /tb_control/PCin_o
add wave -noupdate -color Pink /tb_control/Imm1_in_o
add wave -noupdate -color Pink /tb_control/Imm2_in_o
add wave -noupdate -color Pink /tb_control/done_FSM
add wave -noupdate -color Pink /tb_control/PCsel_o
add wave -noupdate -color Pink /tb_control/ALUFN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {311692 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 232
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1528680 ps}
