module top(
  input wire clk,
  input wire shift_button,
  input wire reset_button, transfer_button, mode_alt_button,
  input wire[3:0] DIP_switch,
  output wire H_digitron_CS, L_digitron_CS,
  output wire[7:0] H_digitron, L_digitron,
  output wire[7:0] LED_result,
  output wire[2:0] LD1,
  output wire[2:0] LD2
);

  wire shift_filtered;
  wire reset_filtered;
  wire transfer_filtered;
  wire mode_alt_filtered;
  wire[7:0] data_bus;
  wire signal_line;
  wire[7:0] result_bus;
  wire mode_selector;
  
  wire[2:0] tmp_ld1, tmp_ld2;
  wire[7:0] tmp_led8, tmp_H_digi, tmp_L_digi;
  
  wire[31:0] divide_freq;
  
  // latch CS signal
  assign H_digitron_CS = 0;
  assign L_digitron_CS = 0;
  
  smart_switch SW_shift(.clk(clk), .in_switch(shift_button), .out_wire(shift_filtered));
  smart_switch SW_reset(.clk(clk), .in_switch(reset_button), .out_wire(reset_filtered));
  smart_switch SW_transfer(.clk(clk), .in_switch(transfer_button), .out_wire(transfer_filtered));
  smart_switch SW_mode_alt(.clk(clk), .in_switch(mode_alt_button), .out_wire(mode_alt_filtered));
  
  mode_alter ModeSelecter(.input_pulse(mode_alt_filtered), .output_modeCS(mode_selector));
  divide_selector DivideSelector(.state_select(DIP_switch[3:2]), .cs(mode_selector), .out_divide_freq(divide_freq));
  
  data_input DATA_in(.DIP_switch(DIP_switch), .shift_in(shift_filtered), .out_wire(data_bus), .cs(mode_selector));
  input_display DISPLAYER(.input_data(data_bus), .H_digitron(tmp_H_digi), .L_digitron(tmp_L_digi), .cs(mode_selector), .clk_divide_input(DIP_switch[3:2]));
  
  Man_encoder ME(._input_reg(data_bus), ._output_wire(signal_line), ._clk(clk), ._en(transfer_filtered), ._rst(reset_filtered), ._divide_freq(divide_freq));
  
  assign tmp_ld1[0] = ~signal_line;
  assign tmp_ld1[1] = ~signal_line;
  assign tmp_ld1[2] = ~signal_line;
  
  Man_decoder MD(.input_wire(signal_line), .output_wire(result_bus), .clk(clk), .rst(reset_filtered), .state_out(tmp_ld2));
  
  assign tmp_led8 = ~result_bus;
  
  frequency_divider  FD(.input_led8(tmp_led8), .input_H_digi(tmp_H_digi), .input_L_digi(tmp_L_digi), .input_ld1(tmp_ld1), .input_ld2(tmp_ld2),
					    .output_led8(LED_result), .output_H_digi(H_digitron), .output_L_digi(L_digitron), .output_ld1(LD1), .output_ld2(LD2), 
					    .state_select(DIP_switch[1:0]), .clk(clk), .cs(mode_selector));

endmodule