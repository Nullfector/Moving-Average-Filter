`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 19:15:48
// Design Name: 
// Module Name: test_filtr
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


module test_filtr();

logic clk = 0, rst = 1, fin_adc = 0;
always #5 clk = ~clk;
logic [11:0] in_data = 12'b0, out_data = 12'b0;

filter #(.L(8)) fil(.clk, .rst, .fin_adc, .in_data(in_data), .fin_filter(fin_filter),
                    .init_filter(init_filter), .out_data(out_data));

logic [11:0] stim [0:14] = '{
  12'h180, 12'h188, 12'h190, 12'h198,
  12'h1A0, 12'h1A8, 12'h1B0, 12'h1B8,
  12'h240, 12'h248, 12'h250, 12'h258,
  12'h260, 12'h268, 12'h270
};

initial begin
    rst <= 0;
    in_data <= 12'h180;
    
    for(int i=1;i<15;i++) begin
        #5 fin_adc = 1;
        #5 fin_adc = 0;
        #20 in_data = stim[i];
    end
    
    #5 fin_adc = 1;
    #5 fin_adc = 0;
    $finish;
end

endmodule
