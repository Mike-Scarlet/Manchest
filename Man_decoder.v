`define data_capacity 8
/*
`define RESET 7'b0000001
`define IDLE_HIGH 7'b0000010
`define IDLE_LOW 7'b0000100
`define CLOCKSYNC_HIGH 7'b0001000
`define CLOCKSYNC_LOW 7'b0010000
`define MASK 7'b0100000
`define READ 7'b1000000
*/
`define RESET 3'b001
`define IDLE_HIGH 3'b010
`define IDLE_LOW 3'b100
`define CLOCKSYNC_HIGH 3'b011
`define CLOCKSYNC_LOW 3'b101
`define MASK 3'b110
`define READ 3'b000

module Man_decoder(input_wire, output_wire, clk, rst, state_out);
  /*
   * Manchest Decoder
   *
   * Args:
   *  input_wire: the wire that transmitting Manchest signal
   *  output_wire: a wire that displays decoded result
   *  clk: input clock signal, should be twice faster than Manchest frequency
   *  eoc: "end of conversion" signal
   *  rst(posedge, asynchronous): reset signal
   */
  input input_wire;
  output[`data_capacity - 1:0] output_wire;
  input clk, rst;
  output[2:0] state_out;
  
  reg[2:0] state;
  reg[2:0] next_state;
  
  reg end_of_convert;
  reg read_one_bit;
  reg clock_last_input;
  
  // port for masking
  reg masked_input;
  integer mask_cnt;
  
  integer clock_cnt;
  integer decoded_cnt;
  
  reg[`data_capacity - 1:0] latch_output;
  
  always @ (posedge clk)
    begin
      if(rst)
        state <= `RESET;
      else
        state <= next_state;
    end
    
  always @ (state or masked_input or rst or mask_cnt or end_of_convert or read_one_bit)
    begin
      if(state == `RESET)
        if(!rst)
          next_state = `IDLE_HIGH;
        else
          next_state = `RESET;
      else if(state == `IDLE_HIGH)
        if(masked_input)
          next_state = `IDLE_HIGH;
        else
          next_state = `IDLE_LOW;
      else if(state == `IDLE_LOW)
        if(masked_input)
          next_state = `CLOCKSYNC_HIGH;
        else
          next_state = `IDLE_LOW;
      else if(state == `CLOCKSYNC_HIGH)
        if(masked_input)
          next_state = `CLOCKSYNC_HIGH;
        else
          next_state = `CLOCKSYNC_LOW;
      else if(state == `CLOCKSYNC_LOW)
        if(masked_input)
          next_state = `MASK;
        else
          next_state = `CLOCKSYNC_LOW;
      else if(state == `MASK)
        if(mask_cnt <= 0)
          next_state = `READ;
        else
          next_state = `MASK;
      else if(state == `READ)
        if(end_of_convert == 1)
          if(masked_input)
            next_state = `IDLE_HIGH;
          else
            next_state = `IDLE_LOW;
        else if(read_one_bit == 1)
          next_state = `MASK;
        else
          next_state = `READ;
      else
        next_state = `RESET;
    end
    
  always @ (posedge clk)
    begin
      case(state)
        `RESET:
          begin
            latch_output <= 0;
            mask_cnt <= 0;
            clock_cnt <= 0;
            decoded_cnt <= 0;
            end_of_convert <= 0;
            read_one_bit <= 0;
          end
        `IDLE_HIGH, `IDLE_LOW:
          begin
            //Note: delay some time?
            // end_of_convert <= 0;
            // soft reset
            read_one_bit <= 0;
            clock_cnt <= 0;
            mask_cnt <= 0;
            decoded_cnt <= 0;
          end
        `CLOCKSYNC_HIGH, `CLOCKSYNC_LOW:
          begin
            //Note: Think if we should clear result here
            latch_output <= 0;
            end_of_convert <= 0;
            
            clock_cnt <= clock_cnt + 1;
            mask_cnt <= ((clock_cnt >> 1) + (clock_cnt >> 2));
          end
        `MASK:
          begin
            if(mask_cnt < 0)
              mask_cnt <= 0;
            else if(mask_cnt > 0)
              mask_cnt <= mask_cnt - 1;
            read_one_bit <= 0;
          end
        `READ:
          begin
            if(read_one_bit == 0)
              begin
                if(clock_last_input != input_wire)
                  begin
                    latch_output <= latch_output << 1;
                    latch_output[0] <= ~input_wire;
                    read_one_bit <= 1;
                    decoded_cnt <= decoded_cnt + 1;
                    if(decoded_cnt == `data_capacity - 1)
                      end_of_convert <= 1;
                    else
                      mask_cnt <= ((clock_cnt >> 1) + (clock_cnt >> 2));
                  end
              end
          end
        default:
          begin
          end
      endcase
      clock_last_input <= input_wire;
    end
  
  // input masker
  always @ (mask_cnt or input_wire)
    begin
      if(mask_cnt >= 0)
        begin
          masked_input = input_wire;
        end
      else
        masked_input = masked_input;
    end
  // assign masked_input = input_wire;
  
  assign output_wire = latch_output;
  //assign output_wire = latch_output;

  assign state_out = ~state;
endmodule

// undefine all defined params
`undef data_capacity

`undef RESET
`undef IDLE_HIGH
`undef IDLE_LOW
`undef CLOCKSYNC_HIGH
`undef CLOCKSYNC_LOW
`undef MASK
`undef READ