`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.01.2026 18:59:50
// Design Name: 
// Module Name: filter
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


module filter #(parameter L=4)(input clk, rst, fin_adc, [11:0] in_data,
                               output fin_filter, init_filter, logic [11:0] out_data);
	
  //pierwszy raz w życiu chyba opisze co robie tak żey się nie zgubić
  
  localparam int K = $clog2(L); //do dzielenia potem
  localparam int SUM_W  = 12 + K + 1; //no bo wektor sumy musi być lekko większy aby wynik faktycznie był właściwy
  
  typedef enum {init, fin_init, add_new, old, calcul} states;
  states st, nst;
  
  logic [11:0] ring_buf [0:L-1]; //bufor na dane
  logic [SUM_W-1:0] sum; //aktualna suma
  logic [K:0] cnt; //lcznik próbek
  
  logic [K-1:0] ptr; //coś do potymalizacji działania fifo (bo ostatnio tragicznie było :c)
  
  always @(posedge clk or posedge rst) //fsm
    if(rst)
      st <= init;
  	else
      st <= nst;
  
  always @* begin //stany
    nst = st;
    case(st)
      init: nst = (cnt < L-1) ? init : fin_init;
      fin_init: nst = fin_adc ? add_new : fin_init;
      add_new: nst = old;
      old: nst = calcul;
      calcul: nst = fin_adc ? add_new : calcul;
    endcase
  end
  
  //jak coś z danymi będzie nie ok, to można dodać spisywanie do zmiennej in_data (na wszelki)
  //ale z tego co patrzyłem na nasz nowy fsm1 to raczej sygnał skakać nie powinien
  //albo dobra, na wszelki wypadek zrobie
  
  logic [11:0] our_data;
  
  always @(posedge clk or posedge rst) //działanie machiny
    if(rst) begin //resetowanie wszystkiego
      sum <= 'b0;
      cnt <= 'b0;
      for(int i=0;i<L;i++) ring_buf[i] <= 'b0;
      ptr <= 'b0;
      out_data <= 'b0;
    end
    else begin //gdy nie trzeba resetować
      //fin_adc jest sygnałem informującym o zakończeniu pracy adc - więc tylko wtedy możemy uznać in_data za poprawną
      if(st==init && fin_adc) begin //wkładanie pierwszych danych
        sum <= sum + {{(SUM_W-12){1'b0}},in_data};
      	cnt <= cnt + 'b1;
        ring_buf[ptr] <= in_data;
        
        //chyba if niepotrzebny
        if(ptr == L-1)
          ptr <= 'b0;
        else
            ptr <= ptr + 'b1;
      end
      
      if(st==fin_init && fin_adc) begin
        out_data <= sum + {{(SUM_W-12){1'b0}},in_data} >> K; //to jest dzielenie przez L (o ile L=2^n)
        sum <= sum + {{(SUM_W-12){1'b0}},in_data};
      	cnt <= cnt + 'b1;
        ring_buf[ptr] <= in_data;
        
        if(ptr == L-1)
          ptr <= 'b0;
        else
            ptr <= ptr + 'b1;
        
      end
      //tu już nie sprawdzam fin_adc bo musiał być 1 jeżeli w tym stanie się znaleźliśmy
      if(st==add_new) begin
      //out_data <= sum >> K;
        our_data <= in_data; //na wszelki wypadek (choć chyba huhanie na zimne, no ale z tym nigdy nie wiadomo)
        sum <= sum + {{(SUM_W-12){1'b0}},in_data}; //wcześniej było our_data
      end
      
      if(st==old) begin
        //ring_buf[ptr] <= in_data;
        ring_buf[ptr] <= our_data;
        sum <= sum - {{(SUM_W-12){1'b0}},ring_buf[ptr]};
        
        if(ptr == L-1)
          ptr <= 'b0;
        else
          ptr <= ptr + 'b1;
      end
      
      if(st==calcul) begin
        out_data <= sum >> K; //to jest dzielenie przez L (o ile L=2^n) - ewentualnie (sum >> K)[11:0]
        
        /*if(ptr == L-1)
          ptr <= 'b0;
        else
          ptr <= ptr + 'b1;
		*/  
		//if(fin_adc) our_data <= in_data;
      end
      
    end
  
  assign init_filter = (/*st==fin_init ||*/ st==init ) ? 1 : 0;
  assign fin_filter = (st==add_new) ? 1 : 0;   //<- tu leży ten problem
  
endmodule
