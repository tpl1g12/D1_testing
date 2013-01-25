/////////////////////////////////////////////////////////////////////
// D1 program for keyboard input, encyption, data transfer
// 
// Last Updated: 25/01/13 - Final version (fingers crossed)
//		
//		
/////////////////////////////////////////////////////////////////////

/*

Signal description:

serial_data -> data from the ps2 in a shift register
led -> connected to the LED
valid -> low when data in the serial buffer is valid
serial_out -> data output pin to AVR
serial_clk_out -> clock output to AVR which only clocks during transmission
serial_clk -> a divided clock to clock the AVR-CPLD protocol
Clk -> onboard 50Mhz clock
nReset -> active low reset
ps2_nclk -> wrongly named clock from keyboard
ndata -> wrongly named data from keyboard (active high)

serial_buffer -> the buffer to send to the AVR
serial_counter -> counts to 8 so the clock and data are sent once only
test_scale -> a 25Mhz clock to test some of the clock scaling
//^a real design would remove this as it causes HF noise
clk_counter -> a counter to scale the clock for AVR-CPLD transmission

lfsr -> shift register for the lfsr
next_lfsr -> combinational result of taps to be fed into lfsr

*/
module ps2 #(parameter N = 11)(output logic [N-1:0] serial_data,  
		output logic led, valid, serial_out, serial_clk_out, serial_clk,
	    input logic Clk, nReset, ps2_nclk, ndata);

logic [N-4:0] serial_buffer;
logic [3:0] serial_counter ;
logic test_scale;
logic [12:0] clk_counter;
		 
logic [3:0] send_serial_count;
logic show_serial_clock;
	
logic [16-1:0] lfsr;
logic next_lfsr;

//lfsr
//Clocked with keyboard
//This means the parity, start and stop will clock the lfsr too
//this means the AVR has to account for this and increment the
//decrypt lfsr extra times
always_ff @(posedge ps2_nclk, negedge nReset)
begin: SEQ1
	if (!nReset)
		begin
			//Seed to start the lfsr
			//'0 will be unencrypted
			lfsr[16-1:0] <= '1; //edited from '0 on 25
		end
	else
		begin
			//Shift new value in using concatenation
			lfsr <= {lfsr[16-2:0], next_lfsr};
		end
end
  
always_comb
begin: COM1
	//Addressed from 0
	//so taps at 10 12 13 15
	next_lfsr = (((lfsr[13]^lfsr[15])^lfsr[12])^lfsr[10]);
end

  
//Clock division for CPLD-AVR
//divide by 5000 counter for 100kHz clock
always_ff @(posedge Clk, negedge nReset)
begin: SEQ4
	if (!nReset)
	begin
		clk_counter <= '0;
		serial_clk<= '0;
	end
	else
	begin
		//Count to 5000
		if ((clk_counter < 8'b11111001) )
		begin
			clk_counter++;
		end
		else
		begin
			clk_counter <= '0;
			//invert the output
			serial_clk<= ~serial_clk;
		end
	end
end

always_comb
begin: COM6
	//Purely a testing routine
	//LSBs of counters oscillate
	test_scale = clk_counter[0];
end
  
//Poll valid for when it goes low
//enable the show_serial_clock flag
//count to 8 and output each bit
//reset the counter when data is no longer valid (~valid)
//....Poll valid..
always_ff @(negedge serial_clk,negedge nReset)
begin: SEQ6
	if (!nReset)
	begin
		//send_serial_flag <= '0;
		send_serial_count <= '0;
		show_serial_clock <= '0;
		serial_out <= '0;
	end
	else if(valid)
	begin
		//send_serial_flag = '0;
		send_serial_count <= 4'b0000;
		show_serial_clock <= '0;
		serial_out <= '0;
	end
	else if (~valid)
	begin
		if(send_serial_count == 4'b0000)
		begin
			//clock out and send data
			serial_out <= serial_buffer[7];
			show_serial_clock <= '1;
			send_serial_count++;
		end 
		else if(send_serial_count == 4'b0001)
		begin
			//clock out and send data
			serial_out <= serial_buffer[6];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0010)
		begin
			//clock out and send data
			serial_out <= serial_buffer[5];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0011)
		begin
			//clock out and send data
			serial_out <= serial_buffer[4];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0100)
		begin
			//clock out and send data
			serial_out <= serial_buffer[3];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0101)
		begin
			//clock out and send data
			serial_out <= serial_buffer[2];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0110)
		begin
			//clock out and send data
			serial_out <= serial_buffer[1];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		else if(send_serial_count == 4'b0111)
		begin
			//clock out and send data
			serial_out <= serial_buffer[0];
			show_serial_clock <= '1;
			send_serial_count++;
		end
		//dummy state for last edge
		else if(send_serial_count == 4'b1000)
		begin
			//clock out and send data
			serial_out <= serial_buffer[0];
			show_serial_clock <= '0;
			send_serial_count++;
		end
		//Dumy state to act as a hold time
		//Was not needed as AVR clocked on rising edge
		/*else
		begin
			show_serial_clock <= '0;
			serial_out <= 0;
		end*/
	end
end

//AND the clock with the show flag to only show
//the clock 8 times as controlled by the previous ff block
always_comb
begin: COM7
	serial_clk_out = serial_clk & show_serial_clock;
end

//Removed this assignment
//the buffer should be unchanged between
//valid cycles so that it appears to be clocked
//by the valid flag
//This allows processes to poll the valid flag or
//be clocked by it and always have valid information
//It is instead set in the next block at the same time as the valid flag
always_comb
begin: COM5
    //serial_buffer = (serial_data[9:1] ^lfsr[15:7]);
end

//PS2 clocked shift register
//For getting raw data
always_ff @(negedge ps2_nclk, negedge nReset)
begin: SEQ2
	if (!nReset)
	begin
		//Just a reset but light the LED for peace of mind
		serial_data[N-1:0] <= '0; //edited from :1 to :0 on 25
		led <= 1;
		serial_counter <= '0;
		valid <= 1;
    end
	else
    begin
		led <= 0;
		//Count to 8 to toggle valid at the end of each byte
		if ((serial_counter < 4'b1010) )
		begin
			valid <= '1; 
			serial_data <= {serial_data[N-2:0], ndata};
			serial_counter <= (serial_counter+1);	
			led <=0;
		end
		else
		begin
			serial_counter <= '0;
			valid <= '0;
			//Write the encrypted byte to the buffer
			//ignoring start, stop, parity and the wasted
			//combinations of the lfsr due to the clock
			//running for these bits but these bits not being sent.
			//This means the real XOR data is not truly an lfsr
			//as some states are missed out.
			//Security through obscurity? ;)
			//.........
			//OK, no.
			serial_buffer = (serial_data[9:1] ^lfsr[15:7]);
		end
	end
end

//Commented out to remove complexity but should cause no problems
//This should be NOT'ed then AND'ed with the valid flag
//as it is 1 when parity is odd valid should be 0 when data is valid
always_comb
begin: COM2
	//paritycheck = ((((((((serial_data[9]^serial_data[8])^serial_data[7])^serial_data[6])^serial_data[5])^serial_data[4])^serial_data[3])^serial_data[2])^serial_data[1]);
end
endmodule


