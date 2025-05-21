Lab 3 – Simple RISC Multi-Cycle CPU Design  
========================================================  

This project implements a simple RISC multi-cycle CPU with a two-bus datapath in VHDL. Instructions are fetched from on-chip program memory, decoded by an FSM-controlled unit, and executed over multiple clock cycles. The datapath uses two internal buses and bidirectional tri-state pins to route data between registers, ALU, and memories. A top-level module ties together Control and Datapath components and provides testbench hooks for loading and inspecting both instruction (ITCM) and data memory (DTCM).

--------------------------------------------------------  
AUX_PACKAGE.VHD  
  Contains component declarations for all modules (ProgMem, DataMem, FA, ALU, IR, PCarchitecture, OPCdecoder, RF, DLatch, DFF, BidirPin, Control, Datapath, Top). Enables clean instantiation across the design.

--------------------------------------------------------  
PROGMEM.VHD  
  Generics: Dwidth, Awidth, depth  
  Ports:  
    clk       – clock input  
    memEn     – write‐enable for instruction memory  
    WmemData  – data bus to write instruction  
    WmemAddr, RmemAddr – write/read address buses  
    RmemData  – output: fetched instruction  
  Functionality: On each rising clk, if memEn = '1' writes WmemData into instruction RAM at WmemAddr; always drives instruction at RmemAddr to RmemData for fetch stage.

--------------------------------------------------------  
DATAMEM.VHD  
  Generics and ports identical to ProgMem but used for data memory.  
  Functionality: On rising clk, reads the word at RmemAddr; if memEn = '1' writes WmemData into address WmemAddr. Supports load/store in two phases of the multi-cycle.

--------------------------------------------------------  
RF.VHD (Register File)  
  Generics: Dwidth, Awidth  
  Ports:  
    clk, rst            – clock and synchronous reset  
    WregEn              – write‐enable  
    WregData, WregAddr  – data and address for write  
    RregAddr            – address for read  
    RregData            – read data output  
  Functionality: Implements 2^Awidth registers. On reset, register 0 is cleared. On rising clk, if WregEn = '1', writes WregData into WregAddr. Always outputs contents of RregAddr.

--------------------------------------------------------  
PCARCHITECTURE.VHD (Program Counter)  
  Generics: Awidth, offset_size, depth  
  Ports:  
    clk, PCin          – clock and load‐enable for next PC  
    IRin_offset        – immediate offset from IR  
    PCsel (2-bit)      – selects next PC source  
    PCout              – current PC output  
  Functionality: Maintains PC. When PCin = '1', loads either PC+1 or PC+1+sign-extended offset based on PCsel. Drives PCout for instruction fetch.

--------------------------------------------------------  
IR.VHD (Instruction Register)  
  Generics: Dwidth, OPC_size, Reg_size, offset_size, Imm_size  
  Ports:  
    DataOut_i          – instruction word from ProgMem  
    RFaddr_rd, RFaddr_wr – register-file addresses  
    IRin               – enable capture of DataOut_i  
    OPC_o              – opcode output  
    IRaddr_rd, IRaddr_wr – decoded RF read/write addresses  
    Imm4_o, Imm8_o     – 4-bit and 8-bit immediate fields  
  Functionality: On IRin = '1' latches fetched instruction, splits into opcode, register addresses, and immediates. Routes correct register fields to RF ports.

--------------------------------------------------------  
OPCDECODER.VHD  
  Generic: OPC_size = 4  
  Ports:  
    OPC       – 4-bit opcode input  
    add, sub, and_OPC, or_OPC, xor_OPC, jmp, jc, jnc, mov, ld, st, done – one-hot control outputs  
  Functionality: Decodes opcode into individual control signals.

--------------------------------------------------------  
FA.VHD (Full Adder)  
  Ports: xi, yi, cin – one-bit inputs  
         s, cout    – sum and carry outputs  
  Functionality: Basic one-bit full-adder used to build ripple-carry adder/subtractor in ALU.

--------------------------------------------------------  
ALU.VHD  
  Generics: Dwidth  
  Ports:  
    A, B       – Dwidth-bit operands  
    ALUFN      – 4-bit function select  
    C          – Dwidth-bit result  
    Cflag, Zflag, Nflag – carry, zero, negative flags  
  Functionality:  
    • Addition/subtraction via chained FA instances  
    • Bitwise AND, OR, XOR, MOV (pass-through)  
    • Updates flags based on result  
    • Supports two-bus tri-state scheme

--------------------------------------------------------  
DLATCH.VHD & DFF.VHD  
  DLATCH: level-sensitive latch with enable and sync reset  
  DFF: master-slave flip-flop on rising clk with enable and sync reset  
  Functionality: Latch results from ALU and memory into intermediate registers (e.g., A, B latches) to sequence multi-cycle operations.

--------------------------------------------------------  
BIDIRPIN.VHD  
  Generic: width  
  Ports:  
    Dout, en  – data out and drive enable  
    Din       – data in  
    IOpin     – inout tri-state pin  
  Functionality: When en = '1', drives Dout onto IOpin; otherwise IOpin floats. Always captures IOpin into Din. Used to implement two-bus tri-state datapath.

--------------------------------------------------------  
CONTROL.VHD  
  Generics: Dwidth, Awidth, offset_size, depth, OPC_size, Reg_size  
  Inputs:  
    clk, rst, ena  
    decoder signals (add_i, sub_i, …)  
    flags (Nflag_i, Zflag_i, Cflag_i)  
  Outputs:  
    mem_wr, mem_in, A_in, RF_in, RF_out, IR_in, PC_in, Imm1_in, Imm2_in, PCsel, ALUFN, RFaddr_wr, RFaddr_rd, done_FSM  
  Functionality: Implements a finite-state machine (Reset, Fetch, Decode, Execute, Memory, Write-Back). In each state asserts control signals to sequence instruction fetch, decode, ALU operation, memory access, branch resolution, and write-back.

--------------------------------------------------------  
DATAPATH.VHD  
  Generics and ports match Control outputs plus memory, IR, RF, and ALU interfaces  
  Functionality: Wires together ProgMem, PCarchitecture, IR, OPCdecoder, RF, ALU, latches, BidirPin, and DataMem.  
    1. Fetch instruction via PC and ProgMem  
    2. Decode and read registers via IR and RF  
    3. Execute ALU operations on two-bus datapath  
    4. Perform load/store via DataMem  
    5. Write back results to RF or PC  
    Intermediate registers implemented with DLatch and DFF modules.

--------------------------------------------------------  
TOP.VHD  
  Generics: sizes for ITCM depth, DTCM depth, data width, address width, etc.  
  Ports:  
    clk, rst, ena  
    TBProgmem_wren, TBProgmem_datain, TBProgmem_wraddr  
    TBDatamem_wren,  TBDatamem_datain,  TBDatamem_wraddr, TBDatamem_rdaddr  
    FSM_done,  TBDatamem_dataout  
  Functionality: Instantiates Control and Datapath, connects testbench signals to load instruction/data memories and observe final data memory contents. Drives ‘done’ output when FSM reaches HALT.

--------------------------------------------------------  
This design cleanly separates control sequencing from datapath operations. The two-bus tri-state scheme allows flexible operand and result routing without a centralized arbiter. Modular packaging and generic parameters make it easy to adjust data widths, address depths, and extend functionality for future lab exercises.

#The lab was created by Omri Aviram and Tal Adoni.#