
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

// FIFO �ӿ��ź�
reg [31:0] RxData_reg;
reg Wen;
wire FIFO_FULL;
wire [8:0] data_count;

// ���н����ź�
reg [35:0] shift_reg;  // ���ڴ洢���յ�����֡
reg [7:0] bit_count;
reg [7:0] Status;

// У���ź�
wire received_checksum;
wire calculated_checksum;

// FIFO ʵ����
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

// У��ͼ���ģ�飨��Tx��ͬ��
CheckSum CS1(shift_reg[33:2], calculated_checksum);

// �ӽ��յ�֡����ȡУ��λ
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

// ��״̬�� - ÿ��clk_wire�����ز���һ��
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
        // Ĭ��ֵ
        wen <= 0;
        checksum_error <= 0;
        frame_error <= 0;
        
        case (Status)
            0: begin  // IDLE״̬���ȴ���ʼλ
                if (Rxd == 1'b1) begin  // ��⵽��ʼλ�ĵ�һλ��START_FLAG[1]��
                    Status <= 1;
                    shift_reg <= {shift_reg[34:0], Rxd};
                    bit_count <= 8'd1;     // �Ѿ��յ�1λ
                end
                else begin
                    shift_reg <= 0;
                    end
            end
            
            1: begin  // ��������֡
                shift_reg <= {shift_reg[34:0], Rxd};
                bit_count <= bit_count + 1;
                
                if (bit_count == 8'd35) begin  // ��������֡��36λ��
                    Status <= 2;  // ����У��״̬
                end
            end
            
            2: begin  // ֡У��
                // �����ʼ��־
                if (shift_reg[35:34] != START_FLAG) begin
                    frame_error <= 1;
                    Status <= 0;  // �ص�IDLE
                end 
                // ���ֹͣλ
                else if (shift_reg[0] != 1'b1) begin
                    frame_error <= 1;
                    Status <= 0;  // �ص�IDLE
                end 
                // ���У���
                else if (received_checksum != calculated_checksum) begin
                    checksum_error <= 1;
                    Status <= 0;  // �ص�IDLE
                end else begin
                    // ���м��ͨ�����洢���ݵ�FIFO
                    RxData_reg <= shift_reg[33:2];  // ��ȡ32λ����
                    wen <= 1;
                    Status <= 3;
                end
            end
            
            3: begin  // ���д�룬�ص�IDLE
                Status <= 0;
            end
            
            default: Status <= 0;
        endcase
    end
end

endmodule