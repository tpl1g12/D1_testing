/////////////////////////////////////////////////////////////////////
// D1 program for keyboard input, encyption, data transfer
// 
// Last Updated: 22/01/13 - Removed the combinational latches.
//        Removed parity. Still just a serial-parallel converter.
//	  Fully tested and works in real life
//        
/////////////////////////////////////////////////////////////////////

module ps2 #(parameter N = 11)(output logic [N-1:0] serial_data,  
        output logic led, valid,
        input logic Clk, nReset, ps2_nclk, ndata, output logic [3:0] serial_counter );

         logic [N-4:0] last_serial_data;
         //logic [6:0] serial_counter ;
         
//enum {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
//      s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30} present_state, next_state;

//enum {t0,t1,t2,t3,t4,t5,t6,t7,t8,t9} ps2_present, ps2_next;
      
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
always_ff @(posedge ps2_nclk, negedge nReset)
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
                valid <= 1;
                serial_data <= {serial_data[N-2:0], ndata};
                serial_counter++;
                //serial_counter <= (serial_counter+1);    
                led <=0;
            end
        else
            begin
            serial_counter <= '0;
            valid <= 0;
            end
        end
    
    //begin
        
    //end
    end


//parity comb
always_comb
  begin: COM2
    
  end

endmodule
