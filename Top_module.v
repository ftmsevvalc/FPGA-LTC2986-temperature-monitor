`timescale 1ns / 1ps

module Top_module(
    input wire clk,
    input wire reset,
    input wire spi_miso,
    output wire spi_mosi,
    output wire spi_sck,
    output wire spi_cs,
    output wire uart_tx
);

    // SPI signals
    wire [7:0] tx0, tx1, tx2, tx3, tx4, tx5, tx6;
    wire [7:0] rx0, rx1, rx2, rx3, rx4, rx5, rx6;
    wire spi_go;
    wire [2:0] spi_n;
    wire spi_ok;
    wire [3:0] ss_state;
    
    // UART signals
    wire uart_start;
    wire [7:0] uart_data;
    wire [2:0] ust_state;
    
    // Temperature signal
    wire temp_ok;

    // SPI Module
    SPI spi_inst (
        .clk(clk),
        .reset(reset),
        .spi_sck(spi_sck),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs(spi_cs),
        .tx0(tx0), 
        .tx1(tx1), 
        .tx2(tx2), 
        .tx3(tx3), 
        .tx4(tx4), 
        .tx5(tx5), 
        .tx6(tx6),
        .rx0(rx0), 
        .rx1(rx1), 
        .rx2(rx2), 
        .rx3(rx3), 
        .rx4(rx4), //sıcaklık verisi
        .rx5(rx5), // sıcaklık verisi
        .rx6(rx6), // sıcaklık verisi
        .spi_go(spi_go),
        .spi_n(spi_n),
        .spi_ok(spi_ok),
        .ss_state(ss_state)
    );

    // UART Module
    Uart_tx uart_inst (
        .clk(clk),
        .reset(reset),
        .uart_start(uart_start),
        .uart_data(uart_data),
        .uart_tx(uart_tx),
        .ust_state(ust_state)
    );

    // FSM Module
    FSM_main fsm_inst (
        .clk(clk),
        .reset(reset),
        .tx0(tx0), 
        .tx1(tx1), 
        .tx2(tx2), 
        .tx3(tx3), 
        .tx4(tx4), 
        .tx5(tx5), 
        .tx6(tx6),
        .rx0(rx0), 
        .rx1(rx1), 
        .rx2(rx2), 
        .rx3(rx3), 
        .rx4(rx4), 
        .rx5(rx5), 
        .rx6(rx6),
        .spi_go(spi_go),
        .spi_n(spi_n),
        .spi_ok(spi_ok),
        .ss_state(ss_state),
        .uart_start(uart_start),
        .uart_data(uart_data),
        .ust_state(ust_state),
        .temp_ok(temp_ok)
    );

endmodule
