module dmem(clk, addr, din, dout, memwrite, memread);
	input 	clk;
	input 	[31:0] 	addr;
	input 	[7:0] 	din;
	input  memwrite; 
	input  memread;
	output 	[7:0] 	dout;
	reg    	[7:0] 	dout;
	reg    	[7:0] 	mem [0:255];
	always @(addr)
		dout = mem[addr];
	always @(posedge clk)
		if (memwrite)
			mem[addr] = din;
endmodule