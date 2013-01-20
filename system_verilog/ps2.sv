/////////////////////////////////////////////////////////////////////
// D1 program for keyboard input, encyption, data transfer
// 
// Last Updated: 20/01/13 - Removed the combinational latches.
//		Removed parity. Still just a serial-parallel converter.
//		
/////////////////////////////////////////////////////////////////////

module ps2 (output logic serial_data[7:0], last_serial_data[7:0], valid, paritycheck,
	    input logic Clk, nReset, ps2_nclk, ndata);

enum {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
      s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30} present_state, next_state;

enum {t0,t1,t2,t3,t4,t5,t6,t7,t8,t9} ps2_present, ps2_next;
	  
//Main clock state machine	
//this is for encryption and the secure wire communication  
//should be done in another block
always_ff @(posedge Clk, negedge nReset)
  begin: SEQ1
	 //Add reset code

  
 end
  
always_comb
  begin: COM1
    
  end

//PS2 clock state machine
//For getting raw data
always_ff @(negedge ps2_nclk, negedge nReset)
  begin: SEQ2
	if (!nReset)
		begin
		ps2_present = t0;
		//paritycheck <= 0;
		end
	else
	begin
		ps2_present = ps2_next;
	end

	valid = 0;
    case(ps2_present)
     t0: begin
		//start bit
          if(ndata)
			begin
				ps2_next = t0;
				
			end
          else
			begin
			valid = 0;
			serial_data[0] <= 0;
			serial_data[1] <= 0;
			serial_data[2] <= 0;
			serial_data[3] <= 0;
			serial_data[4] <= 0;
			serial_data[5] <= 0;
			serial_data[6] <= 0;
			serial_data[7] <= 0; 
			//paritycheck <= 0;
            ps2_next = t1;
			end
          end
		  
	   t1: begin
		//First data bit
			serial_data[7] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t2;
			end
          
	   t2: begin
		//Second data bit
			serial_data[6] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t3;
			end
          
	   t3: begin
		//Third data bit
			serial_data[5] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t4;
			end
       
		t4: begin
		//Fourth data bit
			serial_data[4] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t5;
			end
        
		
		t5: begin
		//Fifth data bit
			serial_data[3] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t6;
			end
		
		t6: begin
		//Sixth data bit
			serial_data[2] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t7;
			end
		
		t7: begin
		//Seventh data bit
			serial_data[1] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t8;
			end
		
		t8: begin
		//Eighth data bit
			serial_data[0] = ~ndata;
			//paritycheck <= paritycheck ^ ndata;
            ps2_next = t9;
			end
		
		t9: begin
		//Parity check and valid flag
		//This state also throws away the stop bit by wasting a clock cycle
			//if (paritycheck)
				//begin
				valid = 1;
				last_serial_data[7:0] = serial_data [7:0];
				//end
            ps2_next = t0;
			end
		  
	endcase
  end


//parity comb
always_comb
  begin: COM2
    
  end

endmodule

