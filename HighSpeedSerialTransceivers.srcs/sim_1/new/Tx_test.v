
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: DeepSeek
// 
// Create Date: 2025/10/13 16:24:09
// Design Name: 
// Module Name: Tx_test
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

module tb_HSS_Tx();

// �����ź�
reg clk_100;
reg clk_wire;
reg rstn;
reg [31:0] Tdata;
reg Wen;

// ����ź�
wire FIFO_FULL;
wire busy;
wire Txd;

// ʵ��������ģ��
HSS_Tx uut (
    .clk_100(clk_100),
    .clk_wire(clk_wire),
    .rstn(rstn),
    .Tdata(Tdata),
    .Wen(Wen),
    .FIFO_FULL(FIFO_FULL),
    .busy(busy),
    .Txd(Txd)
);

// ʱ������
always #5 clk_100 = ~clk_100;  // 100MHz
always #10 clk_wire = ~clk_wire; // 50MHz

// ���Թ���

integer i;
initial begin
    // ��ʼ���ź�
    clk_100 = 0;
    clk_wire = 0;
    rstn = 0;
    Tdata = 0;
    Wen = 0;

    // ��λ
    #50;
    rstn = 1;
    #50;

    // ���ɲ�����5���������

    repeat(2000) begin
        while(FIFO_FULL)begin
            $display("FIFO is full, waiting...");
            #100;
            end
        
        Tdata = $random;  // ����32λ�����
        Wen = 1;
        #10;
        Wen = 0;
        #40;  // �ȴ�һ��ʱ���ٷ�����һ��
        
     
    end

    // �ȴ��������ݷ������
    #15000;
    $display("Test completed.");
    $finish;
end

// ��ش������
initial begin
    $timeformat(-9, 2, " ns", 10);
    $monitor("Time = %t, Txd = %b", $time, Txd);
end

endmodule