`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: YZHY
// 
// Create Date: 2025/09/28 10:54:19
// Design Name: 
// Module Name: HSS_Tx
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


module HSS_Tx(
    input clk_100,
    input clk_wire,
    input rstn,
    input [31:0]Tdata,
    input Wen,
    output FIFO_FULL,
    output reg busy,
    output Txd
    );

parameter START_FLAG = 2'b10;


wire rst;
assign rst = ~rstn;

reg Ren;
wire [31:0]TxCache;
wire FIFO_EMPTY;
wire checkS;
wire [8:0]data_count;

fifo_generator_0 TxBuffer (
  .clk(clk_100),      // input wire clk
  .rst(rst),      // input wire rst
  .din(Tdata),      // input wire [31 : 0] din
  .wr_en(Wen),  // input wire wr_en
  .rd_en(Ren),  // input wire rd_en
  .dout(TxCache),    // output wire [31 : 0] dout
  .full(FIFO_FULL),    // output wire full
  .empty(FIFO_EMPTY),  // output wire empty
  .data_count(data_count)  // output wire [8 : 0] data_count
);

CheckSum CS1(TxCache,checkS);

reg [7:0]Status;
reg [35:0]BtS;
reg [7:0]BitsCnt;
reg read,readdone;

assign Txd = BtS[35];

always @(posedge read or posedge readdone)begin
    if(readdone)
        Ren <= 0;
    else 
        Ren <= 1;
end

always @(posedge clk_100 or negedge rstn)begin
if(!rstn)begin
    readdone <= 1;
    end
else begin
    if(read)readdone <= 1;
    else readdone <= 0;
    end
end

always @(posedge clk_wire or negedge rstn)begin
if(!rstn)begin
    Status <= 0;
    BitsCnt <= 0;
    BtS <= 0;
    read <= 0;
    busy <= 0;
    end
else begin
    case(Status)
    0:begin                 //INIT
        BtS <= 0;
        BitsCnt <= 0;
        read <= 0;
        
        Status <= Status+1;
        end
    
    1:begin                 //Check FIFO 
        if(!FIFO_EMPTY)begin
            read <= 1;
            busy <= 1;
            Status <= Status+1;
            end
        else begin
            busy <= 0;
            Status <= Status;
            end
        end
        
    2:begin                 
        //Ren <= 0;
        Status <= Status+1;
        end
    
    3:begin                 //Load data
        read <= 0;
        BtS <= {START_FLAG,TxCache,checkS,1'b1};
        BitsCnt <= 8'd36;
        Status <= Status+1;
        end
    
    4:begin                 //Check bit
        if(BitsCnt > 0)begin
            BtS <= BtS << 1;
            BitsCnt <= BitsCnt - 1;
            Status <= Status;
            end
        else begin
            Status <= 0;
            end
        end
    
    default :Status <= 0;
    endcase 
    end
end

endmodule
