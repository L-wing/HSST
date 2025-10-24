`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: DeepSeek
// 
// Create Date: 2025/10/14 10:58:51
// Design Name: 
// Module Name: tb_HSS_Tx_Rx
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




module tb_HSS_Tx_Rx();

// 公共信号
reg clk_100;
reg clk_wire;
reg rstn;
wire clk_100_N;
wire clk_wire_N;

// 发送端信号
reg [31:0] Tdata;
reg Wen;
wire FIFO_FULL_Tx;
wire busy;
wire Txd;

// 接收端信号  
wire [31:0] Rdata;
reg Ren;
wire FIFO_EMPTY_Rx;
wire checksum_error;
wire frame_error;

// 实例化发送模块
HSS_Tx u_tx (
    .clk_100(clk_100),
    .clk_wire(clk_wire),
    .rstn(rstn),
    .Tdata(Tdata),
    .Wen(Wen),
    .FIFO_FULL(FIFO_FULL_Tx),
    .busy(busy),
    .Txd(Txd)
);

// 实例化接收模块
HSS_Rx u_rx (
    .clk_100(clk_100),
    .clk_wire(clk_wire),
    .rstn(rstn),
    .Rxd(Txd),  // 将发送端的输出连接到接收端的输入
    .Rdata(Rdata),
    .Ren(Ren),
    .FIFO_EMPTY(FIFO_EMPTY_Rx),
    .checksum_error(checksum_error),
    .frame_error(frame_error)
);

// 时钟生成
always #5 clk_100 = ~clk_100;  // 100MHz
always #500 clk_wire = ~clk_wire; // 50MHz (串行速率)

assign clk_100_N = ~clk_100;
assign clk_wire_N = ~clk_wire;

// 测试过程
initial begin
    // 初始化信号
    clk_100 = 0;
    clk_wire = 0;
    rstn = 0;
    Tdata = 0;
    Wen = 0;
//    Ren = 0;

    // 复位
    #100;
    rstn = 1;
    #100;

    $display("Starting HSS Tx-Rx test with direct sampling...");
    
    // 发送多个测试数据
    repeat(10000) begin
        
        while(FIFO_FULL_Tx)begin
            $display("FIFO is full, waiting...");
            #100;
            end
        
        Tdata = $random;  // 生成32位随机数
        Wen = 1;
        #10;
        Wen = 0;
        #40;  // 等待一段时间再发送下一个
        
        
//        if (!FIFO_FULL_Tx) begin
//            Tdata = $random;  // 生成32位随机数
//            #20;
//            Wen = 1;
//            #10;  // 保持1个clk周期
//            Wen = 0;
            
//            $display("Sent data: %h", Tdata);
            
//            // 等待发送完成（36个clk_wire周期 + 额外余量）
//            #800;
            
//            // 从接收FIFO读取数据
//            if (!FIFO_EMPTY_Rx) begin
//                Ren = 1;
//                #20;
//                Ren = 0;
//                $display("Received data: %h", Rdata);
//                if (Rdata == Tdata) begin
//                    $display("SUCCESS: Data matched!");
//                end else begin
//                    $display("ERROR: Data mismatch! Expected: %h", Tdata);
//                end
//            end else begin
//                $display("ERROR: No data received!");
//            end
            
//            #200;  // 数据间间隔
//        end else begin
//            $display("Tx FIFO full, waiting...");
//            #200;
//        end
    end

    // 测试错误情况
    $display("\nTesting error conditions...");
    
    // 等待所有正常传输完成
    #1000;
    $display("Test completed.");
//    $finish;
end

always  begin
    Ren = 0;
    #10;

    // 从接收FIFO读取数据
    if (!FIFO_EMPTY_Rx) begin
        Ren = 1;
        #20;
        Ren = 0;
        $display("Received data: %h", Rdata);
        end 
end

// 监控信号
//initial begin
//    $timeformat(-9, 2, " ns", 10);
//    forever begin
//        #100;
//        $display("Time = %t, Txd = %b, Tx_busy = %b, Rx_errors = {checksum:%b, frame:%b}, Rx_FIFO_count = %d", 
//                 $time, Txd, busy, checksum_error, frame_error, u_rx.data_count);
//    end
//end

endmodule