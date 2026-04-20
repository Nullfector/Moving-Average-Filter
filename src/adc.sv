`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 18:59:50
// Design Name: 
// Module Name: adc
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


module fsm1 #(parameter led_db = 0) (input clk, rst, enable, data,
    output sclk_adc, cs_adc, fin, output logic [11:0] out_data);
    
    typedef enum {off, await, send, quiet, done} states;
    states st, nst;
    logic [6:0] cnt;
    logic flaga;
    logic [11:0] pom; 
    logic pom_sclk;
    logic pom_sc;
    
    //main counter
    always @(posedge clk, posedge rst)
    if(rst)
        cnt <= 7'b0;
    else if(flaga)
            cnt <= 7'b0;
        else if(cnt == 7'b1011000)
            cnt <= 7'b0;
    else
        cnt <= cnt + 1'b1;
    
    always @(posedge clk, posedge rst)
    if(rst)
        st <= off;
    else
        st <= nst;
    
    //shift register
    always @(posedge clk, posedge rst)
    if(rst)
        pom <= {12{1'b0}};
    else if((cnt >= 7'b0010111) && (cnt < 7'b1010011) && (cnt % 5 == 4))
            pom <= {pom[10:0],data};
        else if(cnt == 7'h57)
            pom <= 12'b0;
    
    //debug
    //assign led = leds;
    generate if(led_db) begin : leds_debug  
    logic [7:0] leds;      
        always @(posedge clk, posedge rst)
        if(rst)
            leds = {8{1'b0}};
        else if( (st == quiet) & (cnt == 7'h55) )
            leds = pom[11:4];
    end
    endgenerate
        
    always @* begin
        nst = off;
        pom_sclk = 1;
        pom_sc = 0;
        flaga = 1'b0;
        
        case(st)
            off:
                begin
                    if(enable) begin
                        nst = await;
                        flaga = 1'b1;
                    end
                end
            await:
                if(cnt == 7'b0000011)
                    nst = send;
                else begin
    
                    nst = await;
                end
            send:
                begin
                    pom_sclk = ((cnt-4 )% 5 > 1);
                    nst = send;
                    if(cnt == 7'b1010011)
                        nst = quiet;
                    end
            quiet:
                begin
                    
                    pom_sc = ((cnt-84 )% 5 > 1);
                    if(cnt == 7'b1011000)
                        nst = done;
                    else
                        nst = quiet;
                    end
             done: nst = off;
        endcase
    end
    
    //output register
    always @(posedge clk, posedge rst)
    if(rst)
        out_data <= 12'b0;
    else if((st == quiet) & (cnt == 7'h56))
        out_data <= pom;
        
    assign fin = (st == done);
    assign cs_adc = (st == off) | (st == done) | pom_sc;
    assign sclk_adc = pom_sclk;
endmodule
