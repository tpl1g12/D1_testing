/////////////////////////////////////////////////////////////////////
// D1 program for keyboard input, encyption, data transfer
// 
// Last Updated: 23/01/13 - Lots of rework. CPLD-AVR protocol
//  
/////////////////////////////////////////////////////////////////////
module ps2 #(parameter N = 11)(output logic [N-1:0] serial_data, 
  output logic led, valid, serial_clk, serial_out, sending,
     input logic Clk, nReset, ps2_nclk, ndata, output logic [3:0] serial_counter, output logic next_lfsr );
   logic [N-4:0] last_serial_data;
   //logic [6:0] serial_counter ;
   logic [12:0] clk_counter;
   logic reset_data;
   
enum {s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,
      s19,s20,s21,s22,s23,s24,s25,s26,s27,s28,s29,s30} present_state, next_state;
//enum {t0,t1,t2,t3,t4,t5,t6,t7,t8,t9} ps2_present, ps2_next;
logic [16-1:0] lfsr;
//lfsr
//not sure which clock.. 
always_ff @(posedge ps2_nclk, negedge nReset)
  begin: SEQ1
  if (!nReset)
   begin
  lfsr[N-1:1] <= '1;
    end
  else
    begin
  lfsr <= {lfsr[N-2:0], next_lfsr};
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
   clk_counter <= '1;
   serial_clk<= '0;
  end
 else
  begin
   if ((clk_counter < 8'b11111001) )
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
 
//send serial data
always_ff @(negedge serial_clk, negedge nReset)
begin: SEQ5
 if (!nReset)
   begin
   //serial_out <= '0;
   present_state <= s0;
   end
 else
     begin
   present_state <= next_state;
   end
end
always_comb
  begin: COM5
  serial_out = '0;
  sending ='1;
  reset_data = '0;
    case(present_state)
  s0: begin
  
   if ((~valid))//nvalid really
   begin
     sending ='0;
    next_state = s1;
   end
   else
   begin
    next_state = s0;
   end
  end

  s1: begin 
    sending = '1;
    serial_out = last_serial_data [7];
    next_state = s2;
  end
  s2: begin 
    serial_out = last_serial_data [6];
    next_state = s3;
  end
  s3: begin 
    serial_out = last_serial_data [5];
    next_state = s4;
  end
  s4: begin 
    serial_out = last_serial_data [4];
    next_state = s5;
  end
  s5: begin 
    serial_out = last_serial_data [3];
    next_state = s6;
  end
  s6: begin 
    serial_out = last_serial_data [2];
    next_state = s7;
  end
  s7: begin 
    serial_out = last_serial_data [1];
    next_state = s8;
  end  
  s8: begin 
    serial_out = last_serial_data [0];
    next_state = s9;
  end
  s9:
  begin
    //serial break cycles
    sending ='0;
    //reset_data = '1; //for stopping multiple presses (experimental)
    next_state =s10;
  end
  s10:
  begin
    //serial break cycles
    sending ='0;
    next_state =s11;
  end
  s11:
  begin
    //serial break cycles
    sending ='0;
    next_state =s12;
  end
  s12:
  begin
    //serial break cycles
    sending ='0;
    next_state =s0;
  end
  
  default: next_state = s0;
  
  endcase
  end
 
 
//PS2 
//For getting raw data
always_ff @(posedge ps2_nclk, negedge nReset, posedge reset_data)
  begin: SEQ2
 
 if (!nReset)
   begin
      serial_data[N-1:1] <= '0;
  led <= 1;
  //serial_counter <= '0;
  serial_counter <= '0;
  valid <= 1;
    end
    
    else if(reset_data)
   begin
     serial_data <= '0;
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
