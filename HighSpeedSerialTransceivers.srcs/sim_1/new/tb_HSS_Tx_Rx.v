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

// �����ź�
reg clk_100;
reg clk_wire;
reg rstn;
wire clk_100_N;
wire clk_wire_N;

// ���Ͷ��ź�
reg [31:0] Tdata;
reg Wen;
wire FIFO_FULL_Tx;
wire busy;
wire Txd;

// ���ն��ź�  
wire [31:0] Rdata;
reg Ren;
wire FIFO_EMPTY_Rx;
wire checksum_error;
wire frame_error;

// ʵ��������ģ��
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

// ʵ��������ģ��
HSS_Rx u_rx (
    .clk_100(clk_100),
    .clk_wire(clk_wire),
    .rstn(rstn),
    .Rxd(Txd),  // �����Ͷ˵�������ӵ����ն˵�����
    .Rdata(Rdata),
    .Ren(Ren),
    .FIFO_EMPTY(FIFO_EMPTY_Rx),
    .checksum_error(checksum_error),
    .frame_error(frame_error)
);

// ʱ������
always #5 clk_100 = ~clk_100;  // 100MHz
always #500 clk_wire = ~clk_wire; // 50MHz (��������)

assign clk_100_N = ~clk_100;
assign clk_wire_N = ~clk_wire;

// ���Թ���
initial begin
    // ��ʼ���ź�
    clk_100 = 0;
    clk_wire = 0;
    rstn = 0;
    Tdata = 0;
    Wen = 0;
//    Ren = 0;

    // ��λ
    #100;
    rstn = 1;
    #100;

    $display("Starting HSS Tx-Rx test with direct sampling...");
    
    // ���Ͷ����������
    repeat(10000) begin
        
        while(FIFO_FULL_Tx)begin
            $display("FIFO is full, waiting...");
            #100;
            end
        
        Tdata = $random;  // ����32λ�����
        Wen = 1;
        #10;
        Wen = 0;
        #40;  // �ȴ�һ��ʱ���ٷ�����һ��
        
        
//        if (!FIFO_FULL_Tx) begin
//            Tdata = $random;  // ����32λ�����
//            #20;
//            Wen = 1;
//            #10;  // ����1��clk����
//            Wen = 0;
            
//            $display("Sent data: %h", Tdata);
            
//            // �ȴ�������ɣ�36��clk_wire���� + ����������
//            #800;
            
//            // �ӽ���FIFO��ȡ����
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
            
//            #200;  // ���ݼ���
//        end else begin
//            $display("Tx FIFO full, waiting...");
//            #200;
//        end
    end

    // ���Դ������
    $display("\nTesting error conditions...");
    
    // �ȴ����������������
    #1000;
    $display("Test completed.");
//    $finish;
end

always  begin
    Ren = 0;
    #10;

    // �ӽ���FIFO��ȡ����
    if (!FIFO_EMPTY_Rx) begin
        Ren = 1;
        #20;
        Ren = 0;
        $display("Received data: %h", Rdata);
        end 
end

// ����ź�
//initial begin
//    $timeformat(-9, 2, " ns", 10);
//    forever begin
//        #100;
//        $display("Time = %t, Txd = %b, Tx_busy = %b, Rx_errors = {checksum:%b, frame:%b}, Rx_FIFO_count = %d", 
//                 $time, Txd, busy, checksum_error, frame_error, u_rx.data_count);
//    end
//end

endmodule