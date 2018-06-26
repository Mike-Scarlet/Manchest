module frequency_divider(input_led8, input_H_digi, input_L_digi, input_ld1, input_ld2,						 output_led8, output_H_digi, output_L_digi, output_ld1, output_ld2, 
						 state_select, clk, cs);
  input clk, cs;
  input[1:0] state_select;
  input[2:0] input_ld1, input_ld2;
  input[7:0] input_led8, input_H_digi, input_L_digi;
  output[2:0] output_ld1, output_ld2;
  output[7:0] output_led8, output_H_digi, output_L_digi;
  
  reg[3:0] cnt_max;
  reg[3:0] counter;
  reg light_switch;
  reg[2:0] output_ld1, output_ld2;
  reg[7:0] output_led8, output_H_digi, output_L_digi;
  
  always @ (state_select, cs)
	begin
	  if(cs)
	    case(state_select)
		  2'b00: cnt_max = 2;
		  2'b01: cnt_max = 1;
		  2'b10: cnt_max = 4;
		  2'b11: cnt_max = 7;
	    endcase
    end
	
  always @ (posedge clk)
	begin
	  counter <= counter + 1;
	  if(counter > cnt_max)
		light_switch <= 0;
	  else
		light_switch <= 1;
	end
	
  always @ (light_switch)
	begin
	  if(light_switch)
		begin
		  output_ld1 = input_ld1;
		  output_ld2 = input_ld2;
		  output_led8 = input_led8;
		  output_H_digi = input_H_digi;
		  output_L_digi = input_L_digi;
		end
	  else
		begin
		  output_ld1 = 3'b111;
		  output_ld2 = 3'b111;
		  output_led8 = 8'b11111111;
		  output_H_digi = 0;
		  output_L_digi = 0;
		end
	end
endmodule