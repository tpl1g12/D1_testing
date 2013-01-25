module test_ps2();

logic [11-1:0] serial_data;
logic led, valid, serial_out, serial_clk_out, serial_clk;
logic Clk, nReset, ps2_nclk, ndata;

ps2 c (.*); // create counter instance

always // clock process
begin
//main onboard fast clock
#1ns Clk = 0;
#1ns Clk = 1;
end



initial // test module
begin
	
	#2ns nReset = 1;
	#2ns nReset = 0;
	#2ns nReset = 1;

	#10ns  ps2_nclk = 1;
	#10ns  ndata = 0;
	//#250ns nReset = 1;
	//Clock in 1 11111111 1 1
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ndata = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ndata = 0;
  #10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	#10ns  ps2_nclk = 1;
	#10ns  ps2_nclk = 0;
	
	
end
endmodule