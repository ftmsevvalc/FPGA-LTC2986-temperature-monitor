`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.11.2025 09:13:50
// Design Name: 
// Module Name: SPI
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


module SPI(
input wire clk,
input wire reset,
    
    output reg spi_sck,
    output reg spi_mosi,
    input wire spi_miso,
    output reg spi_cs,
    
  

   input wire [7:0] tx0,tx1,tx2,tx3,tx4,tx5,tx6, // gönderilen (transmit)
   output reg [7:0] rx0,rx1,rx2,rx3,rx4,rx5,rx6, // alınan (receive)
   input wire spi_go,
   input wire [2:0] spi_n, // bu parametreye göre kaç byte gönderileceği belirleniyor
   output reg spi_ok, // spı işleminin tamamlandığını gösterir
   output wire [3:0] ss_state // ss durumunu dışarı aktar
       );
    wire reset1;
    assign reset1 = ~reset; 
    
    reg [3:0] ss; // ss=0 bekleme , ss=1 yeni byte seçimi , ss=2 ilk bit Mosı ye yüklenir ss=3 sck 1 yapılır veri misodan okunur
                  //ss=4 sck 0 yapılıp bir sonraki bite geçilir , ss=5 byte bittiğinde bir sonraki byte geçilir , 
                  //ss=6 cs=1 işlem tamamlanır spi_ok=1 olur
    reg [7:0] sc; // spı clockunun hızını belirler
    reg [3:0] sb; // bit sayacı
    reg [3:0] si; //byte sayacı
    reg [7:0] st; // spı da gönderilecek geçici byte
     
    assign ss_state =ss;
    
    always @(posedge clk or negedge reset1) begin
        if(!reset1) begin
            ss<=0; spi_cs<=1; spi_sck<=0; spi_mosi<=0; spi_ok<=0; sc<=0; sb<=0; si<=0;
            rx0<=0; rx1<=0; rx2<=0; rx3<=0; rx4<=0; rx5<=0; rx6<=0; 
        end
        else begin
            spi_ok<=0;
            case(ss)
                0: begin 
                spi_cs<=1; 
                spi_sck<=0; 
                    if(spi_go) begin 
                    si<=0; 
                    ss<=1; 
                    end 
                end
                
                1: begin 
                spi_cs<=0; 
                sb<=7; 
                    case(si) 
                    0:st<=tx0; 
                    1:st<=tx1; 
                    2:st<=tx2; 
                    3:st<=tx3; 
                    4:st<=tx4; 
                    5:st<=tx5; 
                    6:st<=tx6; 
                    endcase 
                sc<=0; 
                ss<=2; 
                end
                
                2: begin spi_mosi<=st[sb]; 
                sc<=0; 
                ss<=3; 
                end
                
                3: begin 
                    if(sc<12) 
                    sc<=sc+1; 
                        else begin 
                        spi_sck<=1; 
                            case(si) 
                            0:rx0<={rx0[6:0],spi_miso}; 
                            1:rx1<={rx1[6:0],spi_miso}; 
                            2:rx2<={rx2[6:0],spi_miso}; 
                            3:rx3<={rx3[6:0],spi_miso}; 
                            4:rx4<={rx4[6:0],spi_miso}; 
                            5:rx5<={rx5[6:0],spi_miso}; 
                            6:rx6<={rx6[6:0],spi_miso}; 
                            endcase 
                            sc<=0; 
                            ss<=4; 
                            end 
                        end
                        
                4: begin 
                    if(sc<12) 
                    sc<=sc+1; 
                        else begin 
                        spi_sck<=0; 
                            if(sb==0) 
                            ss<=5; 
                            else begin 
                            sb<=sb-1; 
                            ss<=2; 
                            end 
                        end 
                end
                5: begin 
                    if(si==spi_n-1) 
                    ss<=6; 
                        else begin 
                        si<=si+1; 
                        ss<=1;
                        end 
                end
                6: begin 
                spi_cs<=1; 
                spi_sck<=0; 
                spi_ok<=1; 
                ss<=0; 
                end
                
            endcase
        end
    end
   
    endmodule
