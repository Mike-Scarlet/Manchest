module input_display(input_data, H_digitron, L_digitron, cs, clk_divide_input);
  input cs;
  input[1:0] clk_divide_input;
  input[7:0] input_data;
  output[7:0] H_digitron, L_digitron;
  
  reg[7:0] H_digitron, L_digitron;
  
  always @ (input_data or cs or clk_divide_input)
    begin
	  if(!cs)
		begin
          case(input_data[7:4])
            4'd0: H_digitron = 8'h3f;
            4'd1: H_digitron = 8'h06;
            4'd2: H_digitron = 8'h5b;
            4'd3: H_digitron = 8'h4f;
            4'd4: H_digitron = 8'h66;
            4'd5: H_digitron = 8'h6d;
            4'd6: H_digitron = 8'h7d;
            4'd7: H_digitron = 8'h07;
            4'd8: H_digitron = 8'h7f;
            4'd9: H_digitron = 8'h67;
            4'd10: H_digitron = 8'b01110111;
            4'd11: H_digitron = 8'b01111100;
            4'd12: H_digitron = 8'b00111001;
            4'd13: H_digitron = 8'b01011110;
            4'd14: H_digitron = 8'b01111001;
            4'd15: H_digitron = 8'b01110001;
            default: H_digitron = 8'h80;
          endcase
      
          case(input_data[3:0])
            4'd0: L_digitron = 8'h3f;
            4'd1: L_digitron = 8'h06;
            4'd2: L_digitron = 8'h5b;
            4'd3: L_digitron = 8'h4f;
            4'd4: L_digitron = 8'h66;
            4'd5: L_digitron = 8'h6d;
            4'd6: L_digitron = 8'h7d;
            4'd7: L_digitron = 8'h07;
            4'd8: L_digitron = 8'h7f;
            4'd9: L_digitron = 8'h67;
            4'd10: L_digitron = 8'b01110111;
            4'd11: L_digitron = 8'b01111100;
            4'd12: L_digitron = 8'b00111001;
            4'd13: L_digitron = 8'b01011110;
            4'd14: L_digitron = 8'b01111001;
            4'd15: L_digitron = 8'b01110001;
            default: L_digitron = 8'h80;
          endcase
        end
	  else
		begin
		  case(clk_divide_input)
		    2'b00: //6000000 0.5
			  begin
				H_digitron = 8'hbf;
				L_digitron = 8'h6d;
			  end
		    2'b01: //1200000 0.1
			  begin
				H_digitron = 8'hbf;
				L_digitron = 8'h06;
			  end
		    2'b10: //8
			  begin
				H_digitron = 8'hff;
				L_digitron = 8'h7f;
			  end
		    2'b11: //12000000 1.0
			  begin
				H_digitron = 8'h86;
				L_digitron = 8'h3f;
			  end
		  endcase
		end
    end
endmodule