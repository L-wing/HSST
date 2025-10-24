`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/28 10:54:19
// Design Name: 
// Module Name: HighSpeedSerialTransCeivers
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


module HighSpeedSerialTransCeivers(
    input sys_clk,
    input wire_clk,
    input rstn,
    input smode,
    
    input [31:0]TxData,
    input Wen,
    output [31:0]RxData,
    input Ren,
    output TxFULL,
    output RxEMPTY,
    output [3:0]Status,
    
    output TxD,
    input RxD
    );

wire _clk_wire_speed;
assign _clk_wire_speed = (smode)?wire_clk:sys_clk;

//Status
wire busy;
wire checksum_error;
wire frame_error;
assign Status = {smode,busy,checksum_error,frame_error};

// ʵ��������ģ��
HSS_Tx u_tx (
    .clk_100(sys_clk),
    .clk_wire(_clk_wire_speed),
    .rstn(rstn),
    .Tdata(TxData),
    .Wen(Wen),
    .FIFO_FULL(TxFULL),
    .busy(busy),
    .Txd(TxD)
);

// ʵ��������ģ��
HSS_Rx u_rx (
    .clk_100(sys_clk),
    .clk_wire(_clk_wire_speed),
    .rstn(rstn),
    .Rxd(RxD),  // �����Ͷ˵�������ӵ����ն˵�����
    .Rdata(RxData),
    .Ren(Ren),
    .FIFO_EMPTY(RxEMPTY),
    .checksum_error(checksum_error),
    .frame_error(frame_error)
);


endmodule
