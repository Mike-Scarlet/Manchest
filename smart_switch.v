/*
 * Note: the method to calculate switch_cnt:
 *
 * We desire to test about 200ms
 * the input clk is 12M Hz
 * so the divider should reach 200e-3 * 12e6 = 2400000
 *
 */
`define SWITCH_CNT 2400000
`define SWITCH_RELEASE_CNT 240000
`define SWITCH_ENABLE_VALUE 0

`define SWITCH_IDLE 2'b00
`define SWITCH_TEST 2'b01
`define SWITCH_HOLD 2'b11
`define SWITCH_RELEASE_TEST 2'b10
module smart_switch(clk, in_switch, out_wire);
  input clk, in_switch;
  output out_wire;
  
  integer counter;
  reg out_latch;
  reg[1:0] switch_state;

  always @ (in_switch, counter)
    case(switch_state)
      `SWITCH_IDLE:
        if(in_switch == `SWITCH_ENABLE_VALUE)
          switch_state = `SWITCH_TEST;
      `SWITCH_TEST:
        if(counter > `SWITCH_CNT)
          if(in_switch == `SWITCH_ENABLE_VALUE)
            switch_state = `SWITCH_HOLD;
          else
            switch_state = `SWITCH_IDLE;
      `SWITCH_HOLD:
        if(in_switch != `SWITCH_ENABLE_VALUE)
          switch_state = `SWITCH_RELEASE_TEST;
      `SWITCH_RELEASE_TEST:
        if(counter > `SWITCH_RELEASE_CNT)
      		  if(in_switch == `SWITCH_ENABLE_VALUE)
      		    switch_state = `SWITCH_HOLD;
      		  else
      		    switch_state = `SWITCH_IDLE;
    endcase

  always @ (posedge clk)
	case(switch_state)
	  `SWITCH_IDLE:
		begin
		  out_latch <= 0;
		  counter <= 0;
		end
	  `SWITCH_TEST:
		begin
		  counter <= counter + 1;
		end
	  `SWITCH_HOLD:
		begin
		  counter <= 0;
		  out_latch <= 1;
		end
	  `SWITCH_RELEASE_TEST:
		begin
		  counter <= counter + 1;
		end
	endcase
    
    assign out_wire = out_latch;
endmodule