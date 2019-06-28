module imem (addr, dout);
	input [31:0] addr;
	output [31:0] dout;
	reg    [31:0] dout;
	reg    [31:0] mem [0:255];
	always @(addr)
		dout = mem[addr];
	initial
		$readmemb("prog.txt", mem);
endmodule