onerror {resume}
add list -width 30 /tb_datapath/Datapath_L1/rst
add list /tb_datapath/Datapath_L1/done
add list /tb_datapath/Datapath_L1/TBactive
add list /tb_datapath/Datapath_L1/W_BUS_A
add list /tb_datapath/Datapath_L1/W_BUS_B
add list /tb_datapath/Datapath_L1/RF_L1/sysRF
add list /tb_datapath/Datapath_L1/W_BUS_A
add list /tb_datapath/Datapath_L1/W_BUS_B
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
