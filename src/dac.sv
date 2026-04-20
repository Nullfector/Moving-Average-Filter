`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 18:59:50
// Design Name: 
// Module Name: dac
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


module dacspi #(parameter nbits = 12) (input CLK, RST, SPI_EN, start_init, input [nbits-1:0] SPI_DATA, 
    output SDO, SCLK, SPI_FIN, CS ); 
    	
    typedef enum {Idle, Init, Send, Hold1, Done} states;
    localparam nb = nbits+20, lcnt = $clog2(nb), ldiv = 2; //4
    localparam reg [3:0] cmd = 4'b0011;     //Write to and update DAC Channel addr
    //localparam reg [3:0] addr = 4'b0000;    //DAC A
    localparam reg [3:0] addr = 4'b1111;    //all channels
       
	states current_state, next;		// Signal for state machine	
	reg [nb-1:0] shift_register;		// Shift register to shift out SPI_DATA saved when SPI_EN was set
	reg [lcnt:0] shift_counter;			// Keeps track how many bits were sent
	//wire clk_divided;						// Used as SCLK
	reg [ldiv:0] counter;				// Count clocks to be used to divide CLK
	reg temp_sdo;							// Tied to SDO
    wire sh;
    reg tmp;
    
	wire [nb-1:0] data = {4'b0000, cmd, addr, SPI_DATA, 7'h00, 1'b1}; 
	assign CS = (current_state == Idle && SPI_EN == 1'b0) ? 1'b1 : 1'b0;
	assign SPI_FIN = (current_state == Done) ? 1'b1 : 1'b0;
	// wyjsciowa linia danych mosi
	assign SDO = CS?1'b0:temp_sdo;
		  
	//  rejestr stan
	always @(posedge CLK) 
		if(RST == 1'b1) 					// Synchronous RST
			current_state <= Idle;
		else 
		    current_state <= next;	
		    
    //logika automatu
	always @* begin
	next = Idle;
				case(current_state)
					Idle : next = SPI_EN?Send:start_init?Init:Idle;
					Init: next = Send;
					Send : 
						if(last_bit)
							next = Hold1;
						else
						    next = Send;
					Hold1 : 
						next = Done;
					Done : 
						if(~SPI_EN) 
							next = Idle;
						else 
						    next = Done;
				endcase
    end
    
	//generator zegara transmisji (licznik-dzielnik zegara)
	assign SCLK = counter[ldiv];
	always @(posedge CLK, posedge RST) 
	       if(RST)
	           counter <= 5'b0;
		   else if(current_state == Send) 
				counter <= counter + 1'b1;
			else 
				counter <= 5'b0;
				
    //generator zezwolenie sh (detector zbocza opadajacego zegara transmisji)
    assign sh = ~tmp & SCLK;
    always @(posedge CLK)
        if(RST)
            tmp <= 2'b0;
        else
            tmp <= SCLK;
            
     //licznik bitow dcnt       
    assign last_bit = (shift_counter == nb);        	
	always @(posedge CLK) begin
			if(current_state == Idle) begin
					shift_counter <= {(lcnt+1){1'b0}};
			end
			else if(current_state == Send & sh) begin
							shift_counter <= shift_counter + 1'b1;
			end
	end
	
	//rejestr przesuwny i przerzutnik wyjsciowy
	always @(posedge CLK) 
	       if(current_state == Init) begin
	           shift_register <= {4'b0, 4'h8, 16'b0, 8'h01};  //Reference Set-Up Command 
	           temp_sdo <= 1'b1;
			end
			else if(current_state == Idle & SPI_EN) begin
					shift_register <= data;
					temp_sdo <= 1'b0;
			end
			else if(current_state == Send & sh) begin
							temp_sdo <= shift_register[nb-1];
							shift_register <= {shift_register[nb-2:0],1'b0};
					end
					
endmodule
