onerror {resume}
add list -width 17 /tb_control/ena
add list /tb_control/clk
add list /tb_control/Control_L0/rst
add list /tb_control/Control_L0/current_state
add list /tb_control/Control_L0/next_state
add list /tb_control/add_i
add list /tb_control/sub_i
add list /tb_control/and_i
add list /tb_control/or_i
add list /tb_control/xor_i
add list /tb_control/jmp_i
add list /tb_control/jc_i
add list /tb_control/jnc_i
add list /tb_control/mov_i
add list /tb_control/ld_i
add list /tb_control/st_i
add list /tb_control/done_i
add list /tb_control/Nflag_i
add list /tb_control/Zflag_i
add list /tb_control/Cflag_i
add list /tb_control/DTCM_wr_o
add list /tb_control/DTCM_addr_out_o
add list /tb_control/DTCM_addr_in_o
add list /tb_control/DTCM_out_o
add list /tb_control/Ain_o
add list /tb_control/IRin_o
add list /tb_control/RFin_o
add list /tb_control/Control_L0/RFaddr_wr
add list /tb_control/Control_L0/RFaddr_rd
add list /tb_control/RFout_o
add list /tb_control/PCin_o
add list /tb_control/Imm1_in_o
add list /tb_control/Imm2_in_o
add list /tb_control/done_FSM
add list /tb_control/PCsel_o
add list /tb_control/ALUFN
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
