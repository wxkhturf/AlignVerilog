module bram_96x1024(
	clka, 
	ena,
	wea,
	addra, 
	dina, 
	douta, 
	clkb,
	enb,
	web, 
	addrb, 
	dinb, 
	doutb

);

parameter DATA_WIDTH = 96; // 64bit data
parameter ADDR_WIDTH = 10; // 2048 8kbyte

input clka;
input ena;
input enb;
input [ADDR_WIDTH-1:0]addra; 
input [DATA_WIDTH-1:0]dina; 
output reg [DATA_WIDTH-1:0]douta; 
input clkb; 
input [ADDR_WIDTH-1:0]addrb; 
input [DATA_WIDTH-1:0]dinb; 
output reg [DATA_WIDTH-1:0]doutb;
input wea;
input web;




reg [DATA_WIDTH-1:0] mem [(1<<ADDR_WIDTH)-1:0];


reg [DATA_WIDTH-1:0]douta_dly1; 
reg [DATA_WIDTH-1:0]doutb_dly1; 

always @ (posedge clka)
	begin
		if(ena)
			if(wea)
				mem[addra] <= dina;
			else if (!wea) begin
				douta_dly1 <= mem[addra];
				douta      <= douta_dly1;
			end
			else;
		else;
	end
	
always @ (posedge clkb)
	begin 
		if(enb)
			if(web)
				mem[addrb] <= dinb;
			else if (! web) begin
				doutb_dly1 <= mem[addrb];
				doutb 	   <= doutb_dly1;
			end
			else;
		else;
	end
initial begin
        $readmemh("ram.txt", mem); 
    end
always @(posedge clka or posedge clkb)begin
        $writememh("ram.txt", mem);
    end

endmodule

	




