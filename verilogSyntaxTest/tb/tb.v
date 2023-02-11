`timescale 1ns/1ps

module tb;

reg         clk       ;
reg         rst_n     ;
reg         enable    ;
reg [31:0]  ins       ;
reg         ins_valid ;
wire[95:0]  dina      ;
wire[95:0]  dinb      ;

wire [9:0]   addr0    ;
wire [9:0]   addr1    ;
wire         result   ;
wire         done     ;

initial begin
    clk = 1'b0;
    forever #10 clk =  ~clk;
end

initial begin
    rst_n     = 1'b0       ;
    enable    = 1'b0       ;
    ins       = 32'b000000_000000000000_000_000_0_00_01_10_1 ;
    #5
    rst_n     = 1'b1       ;
    #5
    enable    = 1'b1       ;
end

initial begin
    ins_valid = 1'b0           ;
    #20
    ins_valid = 1'b1           ;
    #20
    ins_valid = 1'b0           ;
end
/*
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dina <= 96'd14167100011558905839616  ;
        dinb <= 96'd14167100011558905839616 + 96'd18889467057378554806276 ;
    end else begin
        dina <= dina + 2*96'd18889467057378554806276 ;
        dinb <= dinb + 2*96'd18889467057378554806276 ;
    end
end
*/




//**************************************RAM******************************//
parameter DATA_WIDTH = 96; // 64bit data
parameter ADDR_WIDTH = 10; // 2048 8kbyte

wire                        ram_clka;
wire                        ram_ena;
wire                        ram_enb;
wire  [ADDR_WIDTH-1:0]      ram_addra; 
wire  [DATA_WIDTH-1:0]      ram_dina; 
wire                        ram_clkb; 
wire  [ADDR_WIDTH-1:0]      ram_addrb; 
wire  [DATA_WIDTH-1:0]      ram_dinb; 
wire                        ram_wea;
wire                        ram_web;

wire  [DATA_WIDTH-1:0]      ram_douta; 
wire  [DATA_WIDTH-1:0]      ram_doutb;

assign ram_clka  = clk       ;
assign ram_ena   = 1'b1      ;
assign ram_enb   = 1'b1      ;
assign ram_addra = addr0     ;
assign ram_dina  = 96'd0     ;
assign ram_clkb  = clk       ;
assign ram_addrb = addr1     ;
assign ram_dinb  = 96'd0     ;
assign ram_wea   = 1'b0      ;
assign ram_web   = 1'b0      ;
assign dina      = ram_douta ;
assign dinb      = ram_doutb ;



bram_96x1024 u_bram_96x1024(
    .clka  ( ram_clka  ),
    .ena   ( ram_ena   ),
    .wea   ( ram_wea   ),
    .addra ( ram_addra ),
    .dina  ( ram_dina  ),
    .douta ( ram_douta ),
    .clkb  ( ram_clkb  ),
    .enb   ( ram_enb   ),
    .web   ( ram_web   ),
    .addrb ( ram_addrb ),
    .dinb  ( ram_dinb  ),
    .doutb ( ram_doutb  )
);



endmodule