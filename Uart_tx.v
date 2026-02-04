`timescale 1ns / 1ps

module Uart_tx(
    input wire clk,
    input wire reset,
    input wire uart_start,        // Port olarak eklendi
    input wire [7:0] uart_data,   // Port olarak eklendi
    output wire uart_tx,
    output wire [2:0] ust_state // uart durumunu dişarı aktar
);

    wire reset1;
    assign reset1 = ~reset;
    
    // UART
    reg uart_tx_reg;
    assign uart_tx = uart_tx_reg;
    
    reg [2:0] ust;      // uart fsm state (0=idle, 1=startbit, 2=data bit, 3=stop bit)
    reg [15:0] ucnt;    // bit süresi sayacı
    reg [3:0] ubit;     // gönderilen bit sayacı
    reg [7:0] ubuf;     // gönderilecek veri geçici buffer
    
    assign ust_state =ust; // formatter için durum bilgisi
    
    always @(posedge clk or negedge reset1) begin
        if (!reset1) begin
            ust <= 0;     
            uart_tx_reg <= 1; 
            ucnt <= 0; 
            ubit <= 0;
        end 
        else case(ust)
            0: begin 
                uart_tx_reg <= 1; 
                if(uart_start) begin 
                    ubuf <= uart_data; 
                    ucnt <= 0; 
                    ust <= 1; 
                end 
            end
            
            1: begin 
                uart_tx_reg <= 0; 
                if(ucnt < 103) 
                    ucnt <= ucnt + 1; 
                else begin 
                    ucnt <= 0; 
                    ubit <= 0; 
                    ust <= 2; 
                end 
            end
            
            2: begin 
                uart_tx_reg <= ubuf[ubit]; 
                if(ucnt < 103) 
                    ucnt <= ucnt + 1; 
                else begin 
                    ucnt <= 0; 
                    if(ubit == 7) 
                        ust <= 3; 
                    else 
                        ubit <= ubit + 1; 
                end 
            end
                
            3: begin 
                uart_tx_reg <= 1; 
                if(ucnt < 103) 
                    ucnt <= ucnt + 1; 
                else 
                    ust <= 0; 
            end
        endcase
    end  

endmodule
