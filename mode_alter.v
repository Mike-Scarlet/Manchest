module mode_alter(input_pulse, output_modeCS);
	input input_pulse;
	output output_modeCS;
	
	reg mode_latch;
	
	always @ (posedge input_pulse)
	  mode_latch <= ~mode_latch;
		
	assign output_modeCS = mode_latch;
endmodule