module filter_v2 (input clk, rst, fin_adc, input [11:0] in_data,
    output logic fin_filter, init_filter, logic [11:0] out_data, input [4:0] L);

typedef enum {init, fin_init, add_new, old, calcul} states;
states st, nst;
/* ram_style = "block" */
logic [11:0] ring_buf [0:L-1]; //bufor na dane
initial $readmemh("init_ring_mem.mem", ring_buf);
logic [L+12:0] sum; //aktualna suma
logic [$clog2(L)-1:0] cnt; //lcznik próbek
logic [11:0] sub, tmp;

always @(posedge clk, posedge rst)
    if(rst)
        st <= init; 
    else
        st <= nst;

always @* begin
    nst = init;
    case(st)
        init: nst = (cnt == L-1)?fin_init:init;
        fin_init: nst = fin_adc?add_new:fin_init;
        add_new: nst = old;
        old: nst = calcul;
        calcul: nst = fin_adc?add_new:calcul;
    endcase
end

always @(posedge clk, posedge rst)
    if(rst)
        init_filter <= 1'b1;
    else if( st == fin_init )
        init_filter <= 1'b0;


always @(posedge clk, posedge rst)
    if(rst)
        cnt <= 1'b0;
    else if(fin_adc) 
        cnt <= cnt + 1'b1;
always @(posedge clk)
    case(st)
        old: ring_buf[cnt] <= tmp;
        init: ring_buf[cnt] <= in_data;
    endcase
    
always @(posedge clk)   //, posedge rst)
    if(rst) begin
        sub <= {12{1'b0}};
        tmp <= {12{1'b0}};
    end
    else if(st == add_new) begin
            sub <= ring_buf[cnt];
            tmp <= in_data;
        end

always @(posedge clk, posedge rst)
    if(rst) begin
        sum <= 'b0;
        //for (int i=0;i<L;i++) ring_buf[i] <= 'b0;
    end
    else if(fin_adc) 
        case(st)
            calcul: sum <= $signed(sum) + $signed({1'b0,tmp}) - $signed({1'b0,sub});
            init: sum <= sum + in_data; //tu może też dopisać
            fin_init: sum <= sum + in_data;
         endcase

assign out_data = sum >> $clog2(L);
assign fin_filter = (st==add_new) ? 1 : 0;

endmodule
/////wersja ostateczna