`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/28 10:52:35
// Design Name: 
// Module Name: CacheFifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CacheFifo
    #(
        parameter DEEP = 32,
        parameter WIDE = 32
    )
    (
        input clk,
        input nrst,
        input w_en,
        input [WIDE-1:0]w_data,
        output full,
        input r_en,
        output [WIDE-1:0]r_data,
        output empty
    );

reg [WIDE-1:0]RAM[DEEP-1:0];
reg [15:0]w_p;
reg [15:0]r_p;
reg [15:0]cnt;

assign full = (cnt>=DEEP)?1:0;
assign empty = (cnt==0)?1:0;


endmodule
