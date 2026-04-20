`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 18:59:50
// Design Name: 
// Module Name: top
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

//dodano wejscia guzikow i usunieto guzik reset
module top(
input clk,
input L0,
input L4,
input L8,
input L16,
input in_data,
output sclk_adc, cs_adc,
output sclk_dac, cs_dac,
output din, freq_sample);

logic [11:0] data_adc;
logic [11:0] filtered_data;

wire rst = L0 | L4 | L8 | L16; //sprawienie by nacisniecie kazdego przelacznika wywolywalo reset
logic [4:0] l_value = 0; //ustawienie wartosci poczatkowej L

//always do zbierania wartosci L z guzikow
always_ff @(posedge clk) begin 
  if (L0)
    l_value <= 0;
  else if (L4)
    l_value <= 4;
  else if (L8)
    l_value <= 8;
  else if (L16)
    l_value <= 16;
end

typedef enum {idle, init_dac, cfg_dac, get_adc, wait_adc, put_dac, wait_dac} states;
states st, nst;

wire en_dac = (st == put_dac);
wire en_adc = (st == get_adc);
wire start_init = (st == init_dac);

assign freq_sample = cs_adc;

//ADC SPI connection
fsm1 adc (.clk, .rst, .enable(en_adc), .sclk_adc, .cs_adc, /*.led,*/ 
        .out_data(data_adc), .data(in_data), .fin(fin_adc));
        
filter_v2 filtr(.clk, .rst, .fin_adc, .in_data(data_adc), .fin_filter(fin_filter), .init_filter(init_filter), .out_data(filtered_data), .L(l_value));  //zmiana parametru L na zmienną
  
//DAC SPI connection
dacspi #(.nbits(12)) dac (.CLK(clk), .RST(rst), .SPI_EN(en_dac), .start_init, .SPI_DATA(/*data_adc*/filtered_data), 
    .SDO(din), .SCLK(sclk_dac), .SPI_FIN(fin_dac), .CS(cs_dac) );

//reset nie jest samodzielny
always @(posedge clk) 
    if(rst)
        st <= idle;
    else
        st <= nst;
        
always @* begin
    nst = idle;
    case(st)
        idle: nst = rst ? idle : init_dac;
        init_dac: nst = cfg_dac;
        cfg_dac: nst = fin_dac ? get_adc : cfg_dac;
        get_adc: nst = wait_adc;
        //wait_adc: nst = fin_adc ? put_dac : wait_adc;
        wait_adc: nst = init_filter ? (fin_adc ? get_adc : wait_adc) : ((fin_filter || init_filter) ? put_dac : wait_adc); //finfilter
        put_dac: nst = wait_dac;
        //wait_dac: nst = fin_dac ? get_adc : wait_dac;
        wait_dac: nst = (fin_dac || init_filter) ? get_adc : wait_dac;
    endcase
end

endmodule
