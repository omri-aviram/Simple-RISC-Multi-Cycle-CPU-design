onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/clk
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/rst
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/done
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/TBactive
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/Imm1_in
add wave -noupdate -radix hexadecimal /tb_datapath/Datapath_L1/Imm2_in
add wave -noupdate -radix hexadecimal -childformat {{/tb_datapath/Datapath_L1/RDataOut_ProgMem(15) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(14) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(13) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(12) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(11) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(10) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(9) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(8) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(7) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(6) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(5) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(4) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(3) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(2) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(1) -radix hexadecimal} {/tb_datapath/Datapath_L1/RDataOut_ProgMem(0) -radix hexadecimal}} -subitemconfig {/tb_datapath/Datapath_L1/RDataOut_ProgMem(15) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(14) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(13) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(12) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(11) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(10) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(9) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(8) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(7) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(6) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(5) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(4) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(3) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(2) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(1) {-radix hexadecimal} /tb_datapath/Datapath_L1/RDataOut_ProgMem(0) {-radix hexadecimal}} /tb_datapath/Datapath_L1/RDataOut_ProgMem
add wave -noupdate -group RF -color Magenta -radix hexadecimal /tb_datapath/Datapath_L1/RFaddr_wr
add wave -noupdate -group RF -color Magenta -radix hexadecimal /tb_datapath/Datapath_L1/RFaddr_rd
add wave -noupdate -group RF -color Magenta -radix hexadecimal /tb_datapath/Datapath_L1/RFin
add wave -noupdate -group RF -color Magenta -radix hexadecimal /tb_datapath/Datapath_L1/RFout
add wave -noupdate -group RF -radix unsigned -childformat {{/tb_datapath/Datapath_L1/RF_L1/sysRF(0) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(1) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(2) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(3) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(4) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(5) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(6) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(7) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(8) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(9) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(10) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(11) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(12) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(13) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(14) -radix unsigned} {/tb_datapath/Datapath_L1/RF_L1/sysRF(15) -radix unsigned}} -expand -subitemconfig {/tb_datapath/Datapath_L1/RF_L1/sysRF(0) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(1) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(2) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(3) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(4) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(5) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(6) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(7) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(8) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(9) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(10) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(11) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(12) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(13) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(14) {-radix unsigned} /tb_datapath/Datapath_L1/RF_L1/sysRF(15) {-radix unsigned}} /tb_datapath/Datapath_L1/RF_L1/sysRF
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/RDataOut_ProgMem
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/IRin
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/IR_Imm8
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/IR_Imm4
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/R_OPC
add wave -noupdate -group IR -color Khaki -radix hexadecimal /tb_datapath/Datapath_L1/IRaddr_wr
add wave -noupdate -group IR -color Khaki -radix hexadecimal -childformat {{/tb_datapath/Datapath_L1/IRaddr_rd(3) -radix hexadecimal} {/tb_datapath/Datapath_L1/IRaddr_rd(2) -radix hexadecimal} {/tb_datapath/Datapath_L1/IRaddr_rd(1) -radix hexadecimal} {/tb_datapath/Datapath_L1/IRaddr_rd(0) -radix hexadecimal}} -expand -subitemconfig {/tb_datapath/Datapath_L1/IRaddr_rd(3) {-color Khaki -radix hexadecimal} /tb_datapath/Datapath_L1/IRaddr_rd(2) {-color Khaki -radix hexadecimal} /tb_datapath/Datapath_L1/IRaddr_rd(1) {-color Khaki -radix hexadecimal} /tb_datapath/Datapath_L1/IRaddr_rd(0) {-color Khaki -radix hexadecimal}} /tb_datapath/Datapath_L1/IRaddr_rd
add wave -noupdate -group {BUS A+B} -color Pink /tb_datapath/Datapath_L1/W_BUS_A
add wave -noupdate -group {BUS A+B} -color Pink /tb_datapath/Datapath_L1/W_BUS_B
add wave -noupdate -group PC -color Cyan /tb_datapath/Datapath_L1/PCin
add wave -noupdate -group PC -color Cyan /tb_datapath/Datapath_L1/PCsel
add wave -noupdate -group PC -color Cyan /tb_datapath/Datapath_L1/PCout
add wave -noupdate -group PC -color Cyan /tb_datapath/Datapath_L1/IR_Imm8
add wave -noupdate -group ALU -color {Cornflower Blue} /tb_datapath/Datapath_L1/Ain
add wave -noupdate -group ALU -color {Cornflower Blue} /tb_datapath/Datapath_L1/ALUFN
add wave -noupdate -group ALU -color {Cornflower Blue} /tb_datapath/Datapath_L1/RegA2ALU
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/ITCM_tb_wr
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/ITCM_tb_in
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/ITCM_tb_addr_in
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_tb_wr
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_addr_sel
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_tb_in
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_tb_addr_in
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_tb_addr_out
add wave -noupdate -group {TB Signal (ITCM+DTCM)} /tb_datapath/Datapath_L1/DTCM_tb_out
add wave -noupdate -group DataMem -color White /tb_datapath/Datapath_L1/DTCM_wr
add wave -noupdate -group DataMem -color White /tb_datapath/Datapath_L1/DTCM_out
add wave -noupdate -group DataMem -color White -radix hexadecimal /tb_datapath/Datapath_L1/W_DataMem_BUS_B
add wave -noupdate -group DataMem -color White -radix hexadecimal /tb_datapath/Datapath_L1/W_DataOut_DataMem
add wave -noupdate -group DataMem -color White -radix hexadecimal /tb_datapath/Datapath_L1/dataInDatamem
add wave -noupdate -group DataMem -color White /tb_datapath/Datapath_L1/writeAddrDataMem
add wave -noupdate -group DataMem -color White /tb_datapath/Datapath_L1/readAddrDataMem
add wave -noupdate -group DataMem -color White /tb_datapath/Datapath_L1/wren_DataMem
add wave -noupdate -group DataMem -color {Spring Green} /tb_datapath/Datapath_L1/DTCM_addr_in
add wave -noupdate -group DataMem -color White -radix unsigned /tb_datapath/Datapath_L1/Q_Waddr_DataMem
add wave -noupdate -group DataMem -color White -radix unsigned /tb_datapath/Datapath_L1/W_Waddr_DataMem
add wave -noupdate -group DataMem -color White -radix unsigned /tb_datapath/Datapath_L1/Q_Raddr_DataMem
add wave -noupdate -group DataMem -color White -radix unsigned /tb_datapath/Datapath_L1/W_Raddr_DataMem
add wave -noupdate -color {Spring Green} /tb_datapath/Datapath_L1/DTCM_addr_out
add wave -noupdate -radix unsigned -childformat {{/tb_datapath/Datapath_L1/DataMemPorts/sysRAM(0) -radix unsigned} {/tb_datapath/Datapath_L1/DataMemPorts/sysRAM(1) -radix unsigned} {/tb_datapath/Datapath_L1/DataMemPorts/sysRAM(2) -radix unsigned} {/tb_datapath/Datapath_L1/DataMemPorts/sysRAM(3) -radix unsigned}} -expand -subitemconfig {/tb_datapath/Datapath_L1/DataMemPorts/sysRAM(0) {-radix unsigned} /tb_datapath/Datapath_L1/DataMemPorts/sysRAM(1) {-radix unsigned} /tb_datapath/Datapath_L1/DataMemPorts/sysRAM(2) {-radix unsigned} /tb_datapath/Datapath_L1/DataMemPorts/sysRAM(3) {-radix unsigned}} /tb_datapath/Datapath_L1/DataMemPorts/sysRAM
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/st
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/ld
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/mov
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/add
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/sub
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/jmp
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/jc
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/jnc
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/and_OPC
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/or_OPC
add wave -noupdate -group {OPC tp control signals} -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/xor_OPC
add wave -noupdate -group flags -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/Cflag
add wave -noupdate -group flags -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/Zflag
add wave -noupdate -group flags -color Cyan -radix hexadecimal /tb_datapath/Datapath_L1/Nflag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {841217 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 386
configure wave -valuecolwidth 129
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {751314 ps} {2628213 ps}
