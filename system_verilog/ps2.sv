/////////////////////////////////////////////////////////////////////
// D1 program for keyboard input, encyption, data transfer
// 
// Last Updated: 24/01/13 - CPLD-AVR protocol
//		
//		
/////////////////////////////////////////////////////////////////////

module ps2 #(parameter N = 11)(output logic [N-1:0] serial_data,  
		output logic led, valid, serial_out, serial_clk_out, serial_clk,
		
	    input logic Clk, nReset, ps2_nclk, ndata);

		 logic [N-4:0] last_serial_data;
		 logic [N-4:0] serial_buffer;
		 logic [3:0] serial_counter ;
		 logic test_scale;
		 logic [12:0] clk_counter;
		 
		 
		 logic paritycheck;
		 logic send_serial_flag;
		 logic [3:0] send_serial_count;
		 logic show_serial_clock;
	
//enum {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
//      s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30} present_state, next_state;

//enum {t0,t1,t2,t3,t4,t5,t6,t7,t8,t9} ps2_present, ps2_next;

logic [16-1:0] lfsr;
logic next_lfsr;

//lfsr
//not sure which clock.. 
always_ff @(posedge ps2_nclk, negedge nReset)
  begin: SEQ1
  if (!nReset)
   begin
  lfsr[16-1:0] <= '0;
    end
  else
    begin
  lfsr <= {lfsr[16-2:0], next_lfsr};
  end
 end
  
always_comb
  begin: COM1
    //taps at 10 12 13 15
  //addressed from 0
  next_lfsr = (((lfsr[13]^lfsr[15])^lfsr[12])^lfsr[10]);
  end

  
 //clock division 
always_ff @(posedge Clk, negedge nReset)
  begin: SEQ4
  if (!nReset)
  begin
   clk_counter <= '0;
   serial_clk<= '0;
  end
 else
  begin
   if ((clk_counter < 8'b11111001) )//8'b11111001 for 100khz.. 10'b1111111110 was good
    begin
     clk_counter++;
    end
   else
    begin
     clk_counter <= '0;
      serial_clk<= ~serial_clk;
    end
  end
 end
always_comb
  begin: COM6
		test_scale = clk_counter[0];
  end
  
  
  
  //change this clock
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
		/*else
		begin
			show_serial_clock <= '0;
			serial_out <= 0;
		end*/
	end
end

always_comb
  begin: COM7//////////////////
    serial_clk_out = serial_clk & show_serial_clock;
  end
	  
//Main clock state machine	
//this is for encryption and the secure wire communication  
//should be done in another block
always_ff @(posedge Clk, negedge nReset)
  begin: SEQ5
	 //Add reset code

 end
  
always_comb
  begin: COM5
    serial_buffer = (serial_data[9:1] ^lfsr[15:7]);/////////////////rachel's on a roll
  end

//PS2 clock state machine
//For getting raw data
always_ff @(negedge ps2_nclk, negedge nReset)
  begin: SEQ2
	
	if (!nReset)
	  begin
      serial_data[N-1:1] <= '0;
		led <= 1;
		//serial_counter <= '0;
		serial_counter <= '0;
		valid <= 1;
    end
  else
    begin
		led <= 0;
      if ((serial_counter < 4'b1010) )
			begin
				valid <= '1; //'1
				serial_data <= {serial_data[N-2:0], ndata};
				serial_counter <= (serial_counter+1);	
				led <=0;
			end
		else
			begin
			serial_counter <= '0;
			valid <= '0;
			end
		end
	
	//begin
		
	//end
	end


//parity comb
always_comb
  begin: COM2
    //paritycheck = ((((((((serial_data[9]^serial_data[8])^serial_data[7])^serial_data[6])^serial_data[5])^serial_data[4])^serial_data[3])^serial_data[2])^serial_data[1]);
  end

  
  
  
  
  
endmodule


