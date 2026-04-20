`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.01.2026 18:01:58
// Design Name: 
// Module Name: test_top
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


module tb_top;


  logic clk = 1'b0;
  logic rst = 1'b1;
  logic in_data = 1'b0;

  wire sclk_adc, cs_adc;
  wire sclk_dac, cs_dac;
  //wire fi, ff, fadc;
  wire din, freq_sample;
  //logic [11:0] filtered_data;
logic [31:0] dac_model;
int i;

  // --- DUT ---
  top dut (
    .clk(clk),
    .rst(rst),
    .in_data(in_data),
    .sclk_adc(sclk_adc),
    .cs_adc(cs_adc),
    .sclk_dac(sclk_dac),
    .cs_dac(cs_dac),
    //.fi(fi),
    //.ff(ff),
    //.fadc(fadc),
    .din(din),
    .freq_sample(freq_sample)
    //.filtered_data
  );


  always #5 clk = ~clk;

  // ------------------------------------------------------------
  // ADC model: send 12-bit word MSB-first into dut.adc.data (in_data)
  // while cs_adc is active low. Data is prepared one clk earlier:
  // set bit when cnt%5==3, fsm1 samples when cnt%5==4.
  // ------------------------------------------------------------
  real phase = 0.0;
real dphi  = 2.0*3.1415926535/64.0; // 64 próbki na okres
real amp   = 1500.0;                // amplituda w kodach ADC
real offs  = 2048.0;                // offset (mid-scale dla 12b unsigned)

function automatic logic [11:0] clip12(input integer x);
  if (x < 0)      clip12 = 12'h000;
  else if (x > 4095) clip12 = 12'hFFF;
  else           clip12 = x[11:0];
endfunction
  
  
  task automatic adc_send12(input logic [11:0] word);
    int idx;

    @(negedge cs_adc);

    idx = 0;


    while (cs_adc === 1'b0) begin
      @(posedge clk);

      if ((dut.adc.cnt >= 7'd23) && (dut.adc.cnt < 7'd79) && (dut.adc.cnt % 5 == 3)) begin
        if (idx < 12) begin
          in_data <= word[11 - idx];
          idx++;
        end else begin
          in_data <= 1'b0;
        end
      end
    end


    in_data <= 1'b0;
  endtask


  initial begin
    #5ms;
    $fatal(1, "TIMEOUT: simulation exceeded 5 ms without finishing expected activity.");
  end

logic [11:0] v [0:14] = '{
  12'h180, 12'h188, 12'h190, 12'h198,
  12'h1A0, 12'h1A8, 12'h1B0, 12'h1B8,
  12'h240, 12'h248, 12'h250, 12'h258,
  12'h260, 12'h268, 12'h270
};
int got = 0;

//DAC model 
logic [11:0] dac_sign;
always @(posedge cs_dac) 
    dac_model = 32'b0;
always @(negedge sclk_dac) if(cs_dac == 1'b0) begin
        dac_model[i--] = din;
        if (i == -1) begin
            @(posedge clk) i = 31;
            dac_sign = dac_model[19:8];
        end
    end

  initial begin
    i = 31;
    in_data <= 1'b0;
    repeat (5) @(posedge clk);
    rst <= 1'b0;

    fork
      begin
        /*for(int i=0;i<15;i++) begin
            adc_send12(v[i]);
        end
        
        for(int i=13;i>=0;i--) begin
            adc_send12(v[i]);
        end*/
        for(int i=0;i<2000;i++) begin
            adc_send12(clip12($rtoi(offs + amp*$sin(phase))));
            phase <= phase + dphi;
        end

      end
    join_none

    forever begin
      @(posedge dut.fin_adc);
      got++;
      //$display("[%0t] fin_adc #%0d, adc=%h, filter=%h, dac=%h", $time, got, dut.data_adc, dut.filtered_data, dac_sign);
      if (got == 2000) begin
        $display("[%0t] Got 10 ADC frames. Stopping.", $time);
        #200ns;
        $finish;
      end
    end
  end

endmodule

