module tb_arm8;
  reg clk;
  reg clr;
  core c(clr, clk);
  initial
  begin
    clr = 0;
    clk = 0;
    #10 clr = 1;
  end
  always 
  begin
    #10 clk = ~clk;
  end
endmodule