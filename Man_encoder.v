`define data_capacity 8
`define bit_length 10
`define divide_freq 6000000
`define eot_keep_time 10

`define IDLE 2'b10
`define RESET 2'b00
`define TRANSFER 2'b11

module Man_encoder(_input_reg, _output_wire, _clk, _en, _rst, _divide_freq);
  /*
   * Manchest Encoder
   *
   * Args:
   *  input_reg: the 8 bit register of input, MSB
   *  output_wire: output signal
   *               where 1 means: + -
   *                     0 means: - +
   *  clk: input clock signal, will be divided by "divide_freq" when transferring
   *  en(posedge, asynchronous): enable transferring
   *  rst(posedge, asynchronous): reset signal
   *
   */
  input[`data_capacity - 1:0] _input_reg;
  input[31:0] _divide_freq;
  input _clk, _en, _rst;
  output _output_wire;
  
  reg[1:0] _state;
  reg[1:0] _next_state;
  
  reg[4:0] _trans_cnt;
  reg _end_of_transfer;
  reg[`bit_length - 1:0] _latch_input;
  reg _latch_output;
  integer _divide_cnt;
  integer _eot_cnt;
  
  always @ (posedge _clk)
    begin
      if(_rst)
        _state <= `RESET;
      else
        _state <= _next_state;
    end
  
  // state
  always @ (_rst or _en or _end_of_transfer or _state)
    begin
      if(_state == `RESET)
        _next_state = `IDLE;
      else if(_state == `IDLE && _en && !_end_of_transfer)
        _next_state = `TRANSFER;
      else if(_state == `TRANSFER && _end_of_transfer)
        _next_state = `IDLE;
	  else if(_state != `IDLE && _state != `RESET && _state != `TRANSFER)
		_next_state = `RESET;
    end
  
  // clock
  always @ (posedge _clk)
    begin
	  case(_state)
		`RESET:
          begin
			_trans_cnt <= 0;
            _latch_input <= 0;
			_divide_cnt <= 0;
			_end_of_transfer <= 0;
			_latch_output <= 0;
		  end
		`IDLE:
		  begin
			if(_eot_cnt > 0)
              _eot_cnt <= _eot_cnt - 1;
            else
              _end_of_transfer <= 0;
			_latch_input <= {2'b00, _input_reg};
		  end
		`TRANSFER:
		  begin
			if(_trans_cnt == 0)
            // prepare data
              begin
                //_latch_input <= {2'b00, _input_reg};
                _trans_cnt <= _trans_cnt + 1;
              end
            else
              begin
                if(_divide_cnt > 0)
                  _divide_cnt <= _divide_cnt - 1;
                else if(_trans_cnt <= 2 * `bit_length)
                  begin
                    if(_trans_cnt != 2 * `bit_length)
                      _divide_cnt <= _divide_freq;
                    _trans_cnt <= _trans_cnt + 1;
                    // translate register to wire
                    if(_trans_cnt[0] == 1)
                      // prepare trigger
                      begin
                        _latch_output <= _latch_input[`bit_length - 1];
                      end
                    else
                      // trigger
                      begin
                        _latch_output <= ~_latch_input[`bit_length - 1];
                        _latch_input <= _latch_input << 1;
                      end
                  end
                else // end transfering
                  begin
                    _end_of_transfer <= 1;
                    _trans_cnt <= 0;
                    _eot_cnt <= `eot_keep_time;
                  end
              end
		  end
	  endcase
    end
  assign _output_wire = _latch_output;

endmodule

// undefine all defined params
`undef data_capacity
`undef bit_length
`undef divide_freq
`undef eot_keep_time

`undef IDLE
`undef RESET
`undef TRANSFER