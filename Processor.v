module imem
(	input [5:0]instrindex, //2^6 instructions only because of RAM size
	output [31:0]instr
);
	reg [31:0]RAM[63:0];
	integer i;
	initial begin
		for (i=3;i<64;i=i+1) begin
			RAM[i]=32'b0;
		end
		
		//RAM[0]=32'b00100000000100000000000000000101;//addi $t16,$zero,5
		//RAM[1]=32'b00100000000100010000000000000100;//addi $t17,$zero,4
		//RAM[2]=32'b00000010001100001001000000100000;//add $t18,$t16,$t17
		
		//RAM[0]=32'b00100000000000010000000000000101;//addi $t1,$zero,5
		//RAM[1]=32'b10101100000000010000000000011110;//sw $t1,30($t0) rs=$t0 and rt=$t1
		//RAM[2]=32'b10001100000000100000000000011110;//lw $t2,30($t0)
		
		//main
		//RAM[0]=32'b00100000000000010000000000000101;//addi $t1,$zero,5
		//RAM[1]=32'b00100000000000100000000000000101;//addi $t2,$zero,4 or 5
		//RAM[2]=32'b00010000001000100000000000000001;//beq $t1,$t2,end(offset=1)
		//RAM[3]=32'b00100000000000100000000000000011;//addi $t2,$zero,3
		//RAM[4]=32'b00000000001000100001100000100000;//add $t3,$t2,$t1 -- end
		
		//main
		RAM[0]=32'b00100000000000010000000000000101;//addi $t1,$zero,5
		RAM[1]=32'b00100000000000100000000000000101;//addi $t2,$zero,4 or 5
		RAM[2]=32'b00001000000000000000000000000100;//j end(offset=index)
		RAM[3]=32'b00100000000000100000000000000011;//addi $t2,$zero,3
		RAM[4]=32'b00000000001000100001100000100000;//add $t3,$t2,$t1 -- end
		
	end
	
	assign instr=RAM[instrindex];
endmodule

		
module ALUControl
(	input [1:0]ALUOp,
	input [5:0]Funct,
	output reg [2:0]ALUControlIn
);
	always @(*) begin
		case (ALUOp)
			2'b00: ALUControlIn=3'b010;//add
			2'b01: ALUControlIn=3'b110;//sub
			default : 
				case(Funct)//RTYPE
					6'b100000: ALUControlIn=3'b010;//add
					6'b100010: ALUControlIn=3'b110;//sub
					6'b100100: ALUControlIn=3'b000;//and
					6'b100101: ALUControlIn=3'b001;//or
					6'b101010: ALUControlIn=3'b111;//set on less than
					default: ALUControlIn=3'bxxx;
				endcase
		endcase
	end
endmodule


module dmem
(	input clk,memwrite,
	input [31:0]dataaddr,writedata,
	output [31:0]readdata
);
	reg [31:0] RAM[63:0];
	assign readdata=RAM[dataaddr[31:2]];
	always @(posedge clk) begin
		if (memwrite) begin
			RAM[dataaddr[31:2]]=writedata;
		end
	end
endmodule


module regfile 
(	input clk,
   input we3,
   input [4:0] ra1, ra2, wa3,
   input [31:0] wd3,
   output [31:0] rd1, rd2
);
   reg [31:0] rf[31:0];

	always @ (posedge clk)
		if (we3) rf[wa3] <= wd3;
			
	assign rd1 = (ra1 != 0) ? (rf[ra1]) : 0;
	assign rd2 = (ra2 != 0) ? (rf[ra2]): 0;
endmodule

module ALU
(	input [31:0] a,b,
	input [2:0] ALUControlIn,
	output reg [31:0] result,
	output zero
);
	always @(*) begin
		case (ALUControlIn)
			3'b010: result = a + b;
			3'b110: result = a - b;
			3'b000: result = a & b;
			3'b001: result = a | b;
			3'b111: result = (a<b) ? 32'h00000001 : 32'h00000000;
			default : result=32'bx;
		endcase
	end
	assign zero=(result==32'b0) ? 1'b1 : 1'b0;
endmodule

module mips
(	input clk,reset,
	output [31:0] pc,
	input [31:0] instr,
	output Memwrite,
	output [31:0]ALUout,writedata,
	input [31:0]readdata
);
	wire MemtoReg,Branch,ALUSrc,regdst,RegWrite,jump; 
   wire [1:0]ALUOp; 
	wire [2:0]ALUControlIn;
	
	CU c(instr[31:26],reset,regdst,ALUSrc,MemtoReg,RegWrite,jump,Memwrite,Branch,ALUOp);
	ALUControl ac(ALUOp,instr[5:0],ALUControlIn);
	
	datapath dp(clk, reset, MemtoReg,ALUSrc, regdst,RegWrite,jump,ALUControlIn,pc,instr,ALUout,writedata,readdata,Branch);
endmodule

module datapath
(	input clk,reset,MemtoReg,ALUSrc,regdst,RegWrite,jump,
	input [2:0]ALUControlIn,
	output reg [31:0]pc,
	input [31:0]instr,
	output [31:0]ALUout,writedata,
	input [31:0]readdata,
	input branch
);
	wire pcsrc,zero;
	assign pcsrc=branch & zero;
	
	wire [4:0] writereg; 
   wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch; 
   wire [31:0] signimm, signimmsh; 
   wire [31:0] srca, srcb; 
   wire [31:0] result;
	wire [31:0] jumpaddr;
	
	assign pcplus4=pc+4;
	assign signimm={{16{instr[15]}},instr[15:0]};
	assign signimmsh={signimm[29:0],2'b00};
	assign pcbranch=pcplus4+signimmsh;
	assign jumpaddr={pcplus4[31:28],instr[25:0],2'b00};
		
	assign pcnextbr=pcsrc ? pcbranch:pcplus4;
	assign pcnext=jump ? jumpaddr:pcnextbr;
	always @ (posedge clk or posedge reset) begin
		if (reset)
			pc<=0;
		else
			pc<=pcnext;
		
	end
	
	regfile rf(clk,RegWrite,instr[25:21],instr[20:16],writereg,result,srca,writedata);
	
	assign writereg=regdst ? instr[15:11]:instr[20:16];

	assign result=MemtoReg ? readdata:ALUout;
		
	assign srcb=ALUSrc ? signimm:writedata;
		
	ALU alu(srca,srcb,ALUControlIn,ALUout,zero);
	
endmodule


module CU
(	input [5:0] opcode,
	input reset,
	output reg regdst,ALUSrc,MemtoReg,RegWrite,jump,MemWrite,Branch,
	output reg [1:0] ALUOp
);
	always @(*) begin
		if (reset) begin
			regdst=1'bx;
			ALUSrc=1'bx;
			MemtoReg=1'bx;
			RegWrite=1'bx;
			jump=1'bx;
			MemWrite=1'bx;
			Branch=1'bx;
			ALUOp=2'bxx;
		end
		else begin
			case (opcode)
				6'b000000: begin //R type
						regdst=1'b1;
						ALUSrc=1'b0;
						MemtoReg=1'b0;
						RegWrite=1'b1;
						jump=1'b0;
						MemWrite=1'b0;
						Branch=1'b0;
						ALUOp=2'b10;
					end
				6'b100011: begin //LW
						regdst=1'b0;
						ALUSrc=1'b1;
						MemtoReg=1'b1;
						RegWrite=1'b1;
						jump=1'b0;
						MemWrite=1'b0;
						Branch=1'b0;
						ALUOp=2'b00;
					end
				6'b101011: begin//SW
						regdst=1'b0;
						ALUSrc=1'b1;
						MemtoReg=1'b0;
						RegWrite=1'b0;
						jump=1'b0;
						MemWrite=1'b1;
						Branch=1'b0;
						ALUOp=2'b00;
					end
				6'b000100: begin//BEQ
						regdst=1'b0;
						ALUSrc=1'b0;
						MemtoReg=1'b0;
						RegWrite=1'b0;
						jump=1'b0;
						MemWrite=1'b0;
						Branch=1'b1;
						ALUOp=2'b01;
					end
				6'b001000: begin //ADDI
						regdst=1'b0;
						ALUSrc=1'b1;
						MemtoReg=1'b0;
						RegWrite=1'b1;
						jump=1'b0;
						MemWrite=1'b0;
						Branch=1'b0;
						ALUOp=2'b00;
					end
				6'b000010: begin //J
						regdst=1'b0;
						ALUSrc=1'b0;
						MemtoReg=1'b0;
						RegWrite=1'b0;
						jump=1'b1;
						MemWrite=1'b0;
						Branch=1'b0;
						ALUOp=2'b00;
					end
				default: begin
						regdst=1'bx;
						ALUSrc=1'bx;
						MemtoReg=1'bx;
						RegWrite=1'bx;
						jump=1'bx;
						MemWrite=1'bx;
						Branch=1'bx;
						ALUOp=2'bxx;
					end
			endcase
		end
	end
endmodule


//top level module
module Processor
(	input clk,reset,
	output [31:0] writedata, dataaddr,instrc,
	output memwrite
);
	wire [31:0] pc, instr, readdata;
	
	mips mips(clk,reset,pc,instr,memwrite,dataaddr,writedata,readdata);
	imem imem(pc[7:2],instr);
	dmem dmem(clk,memwrite,dataaddr,writedata,readdata);
	assign instrc=instr;
endmodule
