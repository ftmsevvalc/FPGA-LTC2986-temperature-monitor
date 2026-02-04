`timescale 1ns / 1ps

module FSM_main(
    input wire clk,
    input wire reset,
    
    // SPI interface
    output reg [7:0] tx0, tx1, tx2, tx3, tx4, tx5, tx6,
    input wire [7:0] rx0, rx1, rx2, rx3, rx4, rx5, rx6,
    output reg spi_go,
    output reg [2:0] spi_n,
    input wire spi_ok,
    input wire [3:0] ss_state,  // SPI durumu
    
    // UART interface
    output reg uart_start,
    output reg [7:0] uart_data,
    input wire [2:0] ust_state,  // UART durumu
    
    // Temperature output
    output reg temp_ok
);

    wire reset1;
    assign reset1 = ~reset;
    
    // Main FSM
    reg [7:0] ms;
    reg [31:0] dly;
    reg [23:0] temp;
    
    always @(posedge clk or negedge reset1) begin
        if(!reset1) begin
            ms<=0; 
            dly<=0;
            temp<=0; 
            temp_ok<=0; 
            spi_go<=0; 
            spi_n<=0;
            tx0<=0; tx1<=0; tx2<=0; tx3<=0; tx4<=0; tx5<=0; tx6<=0;
        end else begin
            temp_ok<=0; 
            spi_go<=0;
            case(ms)
                0: begin 
                    dly<=0; 
                    ms<=1; 
                end
                
                1: if(dly<1200000) 
                    dly<=dly+1; 
                   else begin 
                    dly<=0; 
                    ms<=2; 
                   end
                
                2: if(ss_state==0) begin  // SPI boşta mı?
                    tx0<=8'h02;
                    tx1<=8'h02; 
                    tx2<=8'h18;
                    tx3<=8'hE8; 
                    tx4<=8'h17; 
                    tx5<=8'h70; 
                    tx6<=8'h00;
                    spi_n<=7; 
                    spi_go<=1; 
                    ms<=3;
                end
                
                3: if(spi_ok) 
                    ms<=4;
                
                4: if(ss_state==0) begin
                    tx0<=8'h02; 
                    tx1<=8'h02; 
                    tx2<=8'h20;
                    tx3<=8'h79; 
                    tx4<=8'hC6; 
                    tx5<=8'h00; 
                    tx6<=8'h00;
                    spi_n<=7; 
                    spi_go<=1; 
                    ms<=5;
                end
                
                5: if(spi_ok) 
                    ms<=6;
                
                6: if(ss_state==0) begin
                    tx0<=8'h02; 
                    tx1<=8'h00; 
                    tx2<=8'h00; 
                    tx3<=8'h89;
                    spi_n<=4; 
                    spi_go<=1; 
                    dly<=0; 
                    ms<=7;
                end
                
                7: if(spi_ok) 
                    ms<=8;
                
                8: if(dly<3000000) 
                    dly<=dly+1; 
                   else begin 
                    dly<=0; 
                    ms<=9; 
                   end
                
                9: if(ss_state==0) begin
                    tx0<=8'h03; 
                    tx1<=8'h00; 
                    tx2<=8'h00; 
                    tx3<=8'h00;
                    spi_n<=4; 
                    spi_go<=1; 
                    ms<=10;
                end
                
                10: if(spi_ok) begin
                    if(rx3[6]) 
                        ms<=11;
                    else begin 
                        dly<=0; 
                        ms<=8; 
                    end
                end
                
                11: if(ss_state==0) begin
                    tx0<=8'h03; 
                    tx1<=8'h00; 
                    tx2<=8'h30;
                    tx3<=8'h00; 
                    tx4<=8'h00; 
                    tx5<=8'h00; 
                    tx6<=8'h00;
                    spi_n<=7; 
                    spi_go<=1; 
                    ms<=12;
                end
                
                12: if(spi_ok) begin
                    temp <= {rx4, rx5, rx6}; // ölçülen sıcaklık verisi
                    temp_ok <= 1;
                    dly<=0; 
                    ms<=13;
                end
                
                13: if(dly<12000000) 
                    dly<=dly+1; 
                    else begin 
                    dly<=0; 
                    ms<=6; 
                    end
                
                default: ms<=0;
            endcase
        end
    end
    
    // Temperature calculation
    reg [23:0] temp_scaled;  
    reg [3:0] hundreds, tens, ones;
    reg [3:0] dec1, dec2, dec3, dec4;  
    
    always @(*) begin
        temp_scaled = (temp * 10000) >> 12; // ilk 12 bit tam kısım , son 12 bit virgül sonrası ,Gerçek sıcaklık temp/4096 (yani 2^12) 
        hundreds = temp_scaled / 1000000;                    
        tens = (temp_scaled % 1000000) / 100000;             
        ones = (temp_scaled % 100000) / 10000;               
        dec1 = (temp_scaled % 10000) / 1000;                 
        dec2 = (temp_scaled % 1000) / 100;                   
        dec3 = (temp_scaled % 100) / 10;                    
        dec4 = temp_scaled % 10;                             
    end
    
    // UART Formatter
    reg [3:0] ufmt;
    reg [4:0] uidx;
    
    always @(posedge clk or negedge reset1) begin
        if(!reset1) begin
            ufmt<=0; 
            uidx<=0; 
            uart_start<=0; 
            uart_data<=0;
        end else begin
            case(ufmt)
                0: begin
                    uart_start<=0;
                    if(temp_ok) begin
                        uidx<=0; 
                        ufmt<=1;
                    end
                end
                
                1: begin
                    if(ust_state==0) begin  // UART boşta mı?
                        case(uidx)
                            0:  uart_data <= 8'h54; // 'T'
                            1:  uart_data <= 8'h3A; // ':'
                            2:  uart_data <= 8'h20; // ' '
                            3:  if (hundreds == 0) 
                                    uart_data <= 8'h20;
                                else 
                                    uart_data <= hundreds + 8'h30;
                            4:  if (hundreds == 0 && tens == 0) 
                                    uart_data <= 8'h20;
                                else 
                                    uart_data <= tens + 8'h30;
                            5:  uart_data <= ones + 8'h30;
                            6:  uart_data <= 8'h2E; 
                            7:  uart_data <= dec1 + 8'h30;  
                            8:  uart_data <= dec2 + 8'h30;  
                            9:  uart_data <= dec3 + 8'h30;  
                            10: uart_data <= dec4 + 8'h30;  
                            11: uart_data <= 8'h20; 
                            12: uart_data <= 8'h43; 
                            13: uart_data <= 8'h0D; 
                            14: uart_data <= 8'h0A; 
                            default: ufmt<=0;
                        endcase
                        if(uidx<15) begin 
                            uart_start<=1; 
                            uidx<=uidx+1; 
                        end
                    end
                end
                
                default: ufmt<=0;
            endcase
        end
    end

endmodule
