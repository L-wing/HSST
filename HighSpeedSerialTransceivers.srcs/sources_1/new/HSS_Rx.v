
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: DeepSeek
// 
// Create Date: 2025/09/28 10:54:19
// Design Name: 
// Module Name: HSS_Rx
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


`timescale 1ns / 1ps

module HSS_Rx(
    input clk_100,
    input clk_wire,
    input rstn,
    input Rxd,
    output [31:0] Rdata,
    input Ren,
    output FIFO_EMPTY,
    output reg checksum_error,
    output reg frame_error
    );

parameter START_FLAG = 2'b10;

wire rst;
assign rst = ~rstn;

// FIFO 接口信号
reg [31:0] RxData_reg;
reg Wen;
wire FIFO_FULL;
wire [8:0] data_count;

// 串行接收信号
reg [35:0] shift_reg;  // 用于存储接收的完整帧
reg [7:0] bit_count;
reg [7:0] Status;

// 校验信号
wire received_checksum;
wire calculated_checksum;

// FIFO 实例化
fifo_generator_0 RxBuffer (
  .clk(clk_100),          // input wire clk
  .rst(rst),              // input wire rst
  .din(RxData_reg),       // input wire [31 : 0] din
  .wr_en(Wen),            // input wire wr_en
  .rd_en(Ren),            // input wire rd_en
  .dout(Rdata),           // output wire [31 : 0] dout
  .full(FIFO_FULL),       // output wire full
  .empty(FIFO_EMPTY),     // output wire empty
  .data_count(data_count) // output wire [8 : 0] data_count
);

// 校验和计算模块（与Tx相同）
CheckSum CS1(shift_reg[33:2], calculated_checksum);

// 从接收的帧中提取校验位
assign received_checksum = shift_reg[1];


reg wen;
reg wdone;
always @(posedge clk_100 or negedge rstn)begin
if(!rstn)begin
    wdone <= 1;
    end
else begin
    if(wen) wdone <= 1;
    else wdone <= 0;
    end
end

always @(posedge wen or posedge wdone)begin
if(wdone) Wen <= 0;
else Wen <= 1;
end

// 主状态机 - 每个clk_wire上升沿采样一次
always @(posedge clk_wire or negedge rstn) begin
    if (!rstn) begin
        Status <= 0;
        bit_count <= 0;
        shift_reg <= 0;
        wen <= 0;
        RxData_reg <= 0;
        checksum_error <= 0;
        frame_error <= 0;
    end else begin
        // 默认值
        wen <= 0;
        checksum_error <= 0;
        frame_error <= 0;
        
        case (Status)
            0: begin  // IDLE状态，等待起始位
                if (Rxd == 1'b1) begin  // 检测到起始位的第一位（START_FLAG[1]）
                    Status <= 1;
                    shift_reg <= {shift_reg[34:0], Rxd};
                    bit_count <= 8'd1;     // 已经收到1位
                end
                else begin
                    shift_reg <= 0;
                    end
            end
            
            1: begin  // 接收数据帧
                shift_reg <= {shift_reg[34:0], Rxd};
                bit_count <= bit_count + 1;
                
                if (bit_count == 8'd35) begin  // 接收完整帧（36位）
                    Status <= 2;  // 进入校验状态
                end
            end
            
            2: begin  // 帧校验
                // 检查起始标志
                if (shift_reg[35:34] != START_FLAG) begin
                    frame_error <= 1;
                    Status <= 0;  // 回到IDLE
                end 
                // 检查停止位
                else if (shift_reg[0] != 1'b1) begin
                    frame_error <= 1;
                    Status <= 0;  // 回到IDLE
                end 
                // 检查校验和
                else if (received_checksum != calculated_checksum) begin
                    checksum_error <= 1;
                    Status <= 0;  // 回到IDLE
                end else begin
                    // 所有检查通过，存储数据到FIFO
                    RxData_reg <= shift_reg[33:2];  // 提取32位数据
                    wen <= 1;
                    Status <= 3;
                end
            end
            
            3: begin  // 完成写入，回到IDLE
                Status <= 0;
            end
            
            default: Status <= 0;
        endcase
    end
end

endmodule