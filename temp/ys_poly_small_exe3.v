
/*

    ys_poly_small : mode = 3

    for(i=NTRU_N-1; i>0; i--)

        g->coeffs[i] = 3*(g->coeffs[i-1] - g->coeffs[i]);

      g->coeffs[0] = -(3*g->coeffs[0]);

*/

`timescale 1 ns/1 ps
`include "param.v"
`include "ys_poly_small.vh"
module ys_poly_small_exe3(
    
    f_ctr                        ,                            
    ram1_douta                   ,                            
    ram1_doutb                   ,                            
//OUTPUT 
    ram2_dina                    ,                            
    ram2_dinb      )
          
    ;
                         
//INPUT
input                       clk        ;
input                         f_ctr      ;
input   [`DW_PH-1:0]        ram1_douta ;
input   [`DW_PH-1:0]        ram1_doutb ;
//OUTPUT
output  [`DW_PH-1:0]          ram2_dina  ;
output  [`DW_PH-1:0]        ram2_dinb  ;

//REG
reg     [`DW_13-1:0]        data_dly1  ;
//WIRE
wire   [`DW_PH-1:0]           tmp_dina  ;
wire    [`DW_PH-1:0]        tmp_dinb  ;

wire   [`DW_13-1:0]        tmp       ;



assign tmp = -ram1_douta[`DW_13*0 +: `DW_13];


always@(posedge clk) data_dly1        <= ram2_dinb[`DW_13*3 +: `DW_13]        ;

assign tmp_dina[`DW_13*0 +: `DW_13]  = data_dly1                      - ram1_douta[`DW_13*0 +: `DW_13] ;
assign tmp_dina[`DW_13*1 +: `DW_13]  = ram1_douta[`DW_13*0 +: `DW_13] - ram1_douta[`DW_13*1 +: `DW_13] ;
assign tmp_dina[`DW_13*2 +: `DW_13]  = ram1_douta[`DW_13*1 +: `DW_13] - ram1_douta[`DW_13*2 +: `DW_13] ;
assign tmp_dina[`DW_13*3 +: `DW_13]  = ram1_douta[`DW_13*2 +: `DW_13] - ram1_douta[`DW_13*3 +: `DW_13] ;
assign tmp_dinb[`DW_13*0 +: `DW_13]  = ram1_douta[`DW_13*3 +: `DW_13] - ram1_doutb[`DW_13*0 +: `DW_13] ;
assign tmp_dinb[`DW_13*1 +: `DW_13]  = ram1_doutb[`DW_13*0 +: `DW_13] - ram1_doutb[`DW_13*1 +: `DW_13] ;
assign tmp_dinb[`DW_13*2 +: `DW_13]  = ram1_doutb[`DW_13*1 +: `DW_13] - ram1_doutb[`DW_13*2 +: `DW_13] ;
assign tmp_dinb[`DW_13*3 +: `DW_13]  = ram1_doutb[`DW_13*2 +: `DW_13] - ram1_doutb[`DW_13*3 +: `DW_13] ;

assign ram2_dina[`DW_13*0 +: `DW_13]  = f_ctr ? {tmp_dina[`DW_13*0 +: `DW_13] , 1'b0} + tmp_dina[`DW_13*0 +: `DW_13] 
: {tmp , 1'b0} + tmp                                             ;
assign ram2_dina[`DW_13*1 +: `DW_13]  = {tmp_dina[`DW_13*1 +: `DW_13] , 1'b0} + tmp_dina[`DW_13*1 +: `DW_13] ;
assign ram2_dina[`DW_13*2 +: `DW_13]  = {tmp_dina[`DW_13*2 +: `DW_13] , 1'b0} + tmp_dina[`DW_13*2 +: `DW_13] ;
assign ram2_dina[`DW_13*3 +: `DW_13]  = {tmp_dina[`DW_13*3 +: `DW_13] , 1'b0} + tmp_dina[`DW_13*3 +: `DW_13] ;
assign ram2_dinb[`DW_13*0 +: `DW_13]  = {tmp_dinb[`DW_13*0 +: `DW_13] , 1'b0} + tmp_dinb[`DW_13*0 +: `DW_13] ;
assign ram2_dinb[`DW_13*1 +: `DW_13]  = {tmp_dinb[`DW_13*1 +: `DW_13] , 1'b0} + tmp_dinb[`DW_13*1 +: `DW_13] ;
assign ram2_dinb[`DW_13*2 +: `DW_13]  = {tmp_dinb[`DW_13*2 +: `DW_13] , 1'b0} + tmp_dinb[`DW_13*2 +: `DW_13] ;
assign ram2_dinb[`DW_13*3 +: `DW_13]  = {tmp_dinb[`DW_13*3 +: `DW_13] , 1'b0} + tmp_dinb[`DW_13*3 +: `DW_13] ;



endmodule