// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon Oct 13 17:19:40 2025
// Host        : DESKTOP-STTJAP1 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top fifo_generator_0 -prefix
//               fifo_generator_0_ fifo_generator_0_stub.v
// Design      : fifo_generator_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module fifo_generator_0(clk, rst, din, wr_en, rd_en, dout, full, empty, 
  data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[31:0],wr_en,rd_en,dout[31:0],full,empty,data_count[8:0]" */;
  input clk;
  input rst;
  input [31:0]din;
  input wr_en;
  input rd_en;
  output [31:0]dout;
  output full;
  output empty;
  output [8:0]data_count;
endmodule
