onerror {resume}
add list -width 18 /tb_top/TBactive
add list /tb_top/rst
add list /tb_top/ena
add list /tb_top/done_FSM
add list /tb_top/top_L1/Control_Ports/current_state
add list /tb_top/top_L1/DataPath_Ports/RF_L1/sysRF
add list /tb_top/top_L1/DataPath_Ports/W_BUS_B
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
