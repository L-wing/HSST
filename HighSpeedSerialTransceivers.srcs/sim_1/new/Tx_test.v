
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

// 输入信号
reg clk_100;
reg clk_wire;
reg rstn;
reg [31:0] Tdata;
reg Wen;

// 输出信号
wire FIFO_FULL;
wire busy;
wire Txd;

// 实例化被测模块
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

// 时钟生成
always #5 clk_100 = ~clk_100;  // 100MHz
always #10 clk_wire = ~clk_wire; // 50MHz

// 测试过程

integer i;
initial begin
    // 初始化信号
    clk_100 = 0;
    clk_wire = 0;
    rstn = 0;
    Tdata = 0;
    Wen = 0;

    // 复位
    #50;
    rstn = 1;
    #50;

    // 生成并发送5个随机数据

    repeat(2000) begin
        while(FIFO_FULL)begin
            $display("FIFO is full, waiting...");
            #100;
            end
        
        Tdata = $random;  // 生成32位随机数
        Wen = 1;
        #10;
        Wen = 0;
        #40;  // 等待一段时间再发送下一个
        
     
    end

    // 等待所有数据发送完成
    #15000;
    $display("Test completed.");
    $finish;
end

// 监控串行输出
initial begin
    $timeformat(-9, 2, " ns", 10);
    $monitor("Time = %t, Txd = %b", $time, Txd);
end

endmodule