module divide_selector(state_select, cs, out_divide_freq);
  input cs;
  input[1:0] state_select;
  output[31:0] out_divide_freq;
  
  reg[31:0] out_divide_freq;
  
  always @ (state_select, cs)
	begin
	  if(cs)
	    case(state_select)
		  2'b00: out_divide_freq = 6000000;
		  2'b01: out_divide_freq = 1200000;
		  2'b10: out_divide_freq = 8;
		  2'b11: out_divide_freq = 12000000;
	    endcase
    end
endmodule