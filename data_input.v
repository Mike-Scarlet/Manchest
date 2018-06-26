module data_input(DIP_switch, shift_in, out_wire, cs);
  input[3:0] DIP_switch;
  input shift_in, cs;
  output[7:0] out_wire;
  
  reg [7:0] out_latch;
  reg lower;
  
  always @ (posedge shift_in)
	if(!cs)
	  begin
        lower = ~lower;
      end
  
  always @ (DIP_switch, lower, cs)
    begin
	  if(!cs)
        if(lower)
		  out_latch[3:0] = DIP_switch;
        else
          out_latch[7:4] = DIP_switch;
    end
    
  assign out_wire = out_latch;
endmodule