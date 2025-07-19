module Processor_tb; 
    reg clk; 
    reg reset;
    integer i; 
    wire [31:0] writedata, dataadr,instr; 
    wire memwrite; 
    // instantiate device to be tested 
    Processor dut(clk, reset, writedata, dataadr,instr, memwrite); 
    // initialize test 
    initial begin 
        reset <= 1; # 5; reset <= 0; 
    end 
    // generate clock to sequence tests 
    initial begin 
        clk <= 1; # 5; clk <= 0; # 5; 
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
		  clk <= 1; # 5; clk <= 0; # 5;
    end 
    // check results 
    initial begin
		$monitor("clk=%b, reset=%b, instr=%b, out1=%b",clk,reset,instr,dut.mips.dp.rf.rf[3]);  
    end 
endmodule