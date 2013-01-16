module test_ps2();

logic serial_data[7:0], last_serial_data[7:0], valid, paritycheck;
logic Clk, nReset, ps2_nclk, ndata;

ps2 c (.*); // create counter instance

//always // clock process
//begin
//The clock is only active on data send for keyboard
//so this isn't used until the program does more than
//just interface with the keyboard.
//end

initial // test module
begin
	#10ns  ps2_nclk = 1;
	#10ns  ndata = 0;
	#250ns nReset = 1;
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
	
end
endmodule