module core (clr, clk);
	input clr;
	input clk;
	reg [31:0] instrf, instrd, instrx;
	reg [31:0] pcf, pcd, pcx;
	wire [31:0] npc;
	reg pcsrc;
	wire [31:0] npcbx;
	reg [31:0] npcbm;
	reg reg2loc; 
	reg alusrcd, alusrcx; 
	reg memtoregd, memtoregx, memtoregm, memtoregw;
	reg regwrited, regwritex, regwritem, regwritew;
	reg memreadd, memreadx, memreadm;
	reg memwrited, memwritex, memwritem; 
	reg branchd, branchx, branchm;
	reg aluop0d, aluop0x, aluop1d, aluop1x; 
	reg [4:0] rbadd1, rbadd2, rbwaddd, rbwaddx, rbwaddm, rbwaddw; 
	reg[31:0] signexd, signexx;
	wire [31:0] regout1d, regout2d; 
	reg [31:0] regout1x, regout2x, regout2m;
	reg [3:0] aluc;
	reg [31:0]aluin2;
	reg [31:0] rbwdata, aluresx, aluresm, aluresw; 
	wire zerofx;
	reg zerofm;
	wire [31:0] dmemoutm;
	reg [31:0] dmemoutw;
	//************************
	// CLOCK
	//************************
	always @ (negedge clr or posedge clk)
	begin
	  if (!clr)
	  begin
	    pcf = 32'b00000000000000000000000000000000;
	    pcsrc = 0;
	  end
	  else if (clk)
	  begin
			npcbm <= npcbx;
			pcf <= npc;
			pcd <= pcf;
			pcx <= pcd;
			regout2m <= regout2x;
			signexx <= signexd;
			branchx <= branchd;
			branchm <= branchx;
			aluop1x <= aluop1d;
			aluop0x <= aluop0d;
			aluresm <= aluresx;
			aluresw <= aluresm;
			memreadx <= memreadd;
			memreadm <= memreadx;
			memwritex <= memwrited;
			memwritem <= memwritex;
			regwritex <= regwrited;
			regwritem <= regwritex;
			regwritew <= regwritem;
			memtoregx <= memtoregd;
			memtoregm <= memtoregx;
			memtoregw <= memtoregm;
			dmemoutw <= dmemoutm;
			instrd <= instrf;
			instrx <= instrd;
			alusrcx <= alusrcd;
			rbwaddx <= rbwaddd;
			rbwaddm <= rbwaddx;
			rbwaddw <= rbwaddm;
			zerofm <= zerofx;	
	// CLOCK --- FORWARDING
			if (regwritex && rbwaddx != 31 && rbwaddx == rbadd1)
	    begin
	       regout1x <= aluresx;
	    end
	    else if (regwritem && rbwaddm != 31 && !(regwritex && rbwaddx != 31 && rbwaddx != rbadd1) && rbwaddm == rbadd1)
	    begin
	       if (!memtoregm)
	         regout1x <= aluresm;
	       else
	         regout1x <= dmemoutm;
	    end
	    else
	    begin
			   regout1x <= regout1d;
			end
			
			if (regwritex && rbwaddx != 31 && rbwaddx == rbadd2)
	    begin
	       regout2x <= aluresx;
	    end
	    else if (regwritem && rbwaddm != 31 && !(regwritex && rbwaddx != 31 && rbwaddx != rbadd2) && rbwaddm == rbadd2)
	    begin
	       if (!memtoregm)
	         regout2x <= aluresm;
	       else
	         regout2x <= dmemoutm;
	    end
	    else
	    begin
			   regout2x <= regout2d;
			end
		end
	end
	//*******************************************************
	// FETCH
	//*******************************************************
	assign npcbx = signexx + pcx;
	assign npc = (pcsrc == 0) ? pcf + 1 : npcbm;
	always @(branchm or zerofm)
	begin
	  pcsrc = branchm & zerofm;
	end
	wire [31:0] instr2;
	imem im (pcf, instr2);
	always @(instr2)
	   instrf = instr2;
	//*******************************************************
	// DECODE
	//*******************************************************
	always @(instrd)
	begin
	  if (instrd[28:25] == 4'b0101 && instrd[23:21] == 3'b000 && instrd[31] == 1'b1)
    begin
	    reg2loc = 0;
	    alusrcd = 0;
	    memtoregd = 0;
	    regwrited = 1;
	    memreadd = 0;
	    memwrited = 0;
	    branchd = 0;
	    aluop1d = 1;
	    aluop0d = 0;
	  end  
	  if (instrd[31:21] == 11'b11111000010)
	  begin
	    alusrcd = 1;
	    memtoregd = 1;
	    regwrited = 1;
	    memreadd = 1;
	    memwrited = 0;
	    branchd = 0;
	    aluop1d = 0;
	    aluop0d = 0;
	  end   
	  if (instrd[31:21] == 11'b11111000000)
	  begin
	    reg2loc = 1;
	    alusrcd = 1;
	    regwrited = 0;
      memreadd = 0;
	    memwrited = 1;
	    branchd = 0;
	    aluop1d = 0;
	    aluop0d = 0;
	  end    
	  if (instrd[31:24] == 8'b10110100)
	  begin
	    reg2loc = 1;
	    alusrcd = 0;
	    regwrited = 0;
	    memreadd = 0;
	    memwrited = 0;
	    branchd = 1;
	    aluop1d = 0;
	    aluop0d = 1;
	  end
	end
  always @ (aluop0x or aluop1x or instrx)
  begin
    if (aluop1x == 0 && aluop0x == 0)
      aluc = 4'b0010;
    if (aluop0x == 1)
      aluc = 4'b0111;
    if (aluop1x == 1 && instrx[31:21] == 11'b10001011000)
      aluc = 4'b0010;
    if (aluop1x == 1 && instrx[31:21] == 11'b11001011000)
      aluc = 4'b0110;
    if (aluop1x == 1 && instrx[31:21] == 11'b10001010000)
      aluc = 4'b0000;
    if (aluop1x == 1 && instrx[31:21] == 11'b10101010000)
      aluc = 4'b0001;
  end
  // DECODE --- REGISTER READ
	always @(instrd or reg2loc)
	begin
	  rbadd1 = instrd[9:5];
	  if (!reg2loc)
	     rbadd2 = instrd[20:16];
	  else
	     rbadd2 = instrd[4:0];
	  rbwaddd = instrd[4:0];
	end
	reg_bank rb (clk, clr, rbadd1, rbadd2, rbwaddw, rbwdata, regout1d, regout2d, regwritew);
	// DECODE --- SIGN EXTEND
	always @(instrd)
	begin
	  signexd[18:0] = instrd[23:5];
	  if (signexd[25] == 0)
	    signexd[31:19] = 13'b0000000000000;
	  else
	    signexd[31:19] = 6'b11111111111111;
	end
	//*******************************************************
	// EXECUTE
	//*******************************************************	
	// EXECUTE --- ALU
	always @(alusrcx or regout2x or signexx)
	begin
    if (!alusrcx)
      aluin2 = regout2x;
    else
      aluin2 = signexx;
	end
	always @(regout1x, aluin2, aluc)
	begin
	  if (aluc == 4'b0000)
	    aluresx = regout1x & aluin2;
	  if (aluc == 4'b0001)
	    aluresx = regout1x | aluin2;
	  if (aluc == 4'b0010)
	    aluresx = regout1x + aluin2;
	  if (aluc == 4'b0110)
	    aluresx = regout1x - aluin2;
	  if (aluc == 4'b0111)
	    aluresx = aluin2;
	  if (aluc == 4'b1100)
	    aluresx = !(regout1x | aluin2);
	end
	assign zerofx = (aluresx == 0) ? 1 : 0;
	//*******************************************************
	// MEMORY
	//*******************************************************
	dmem dm0(clk, aluresm, regout2m[7:0], dmemoutm[7:0], memwritem, memreadm);
	dmem dm1(clk, aluresm, regout2m[15:8], dmemoutm[15:8], memwritem, memreadm);
	dmem dm2(clk, aluresm, regout2m[23:16], dmemoutm[23:16], memwritem, memreadm);
	dmem dm3(clk, aluresm, regout2m[31:24], dmemoutm[31:24], memwritem, memreadm);
	//************************
	// WRITE BACK
	//************************
	always @(dmemoutw or aluresw or memtoregw)
	begin
	  if (!memtoregw)
	    rbwdata = aluresw;
	  else
	    rbwdata = dmemoutw;
	end
endmodule