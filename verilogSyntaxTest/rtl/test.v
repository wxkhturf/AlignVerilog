module test;
//******************************* assign *********************************************//
wire a,b,c,d,e;
wire ins;
assign ins = a > (b - 1'b1) ?
             c > d  : e       ;     


assign a = 1 'b      1;
endmodule