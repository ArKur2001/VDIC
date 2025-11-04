interface simple_uart_switch_bfm;
  import simple_uart_switch_tb_pkg::*;

  logic clk;    
  logic rst_n;  
  logic prog;   
  logic sin;    
  logic sout0;   
  logic sout1;

  logic[7:0] exp_sout0_frames [];
  logic[7:0] exp_sout1_frames [];

  test_t test;
  test_end_t test_end;
  frame_data_t frame;

  initial begin : clk_gen_blk
    clk = 0;
    forever #10 clk = ~clk;
  end

  task reset_sw();
    rst_n = 0;
    prog = 0;
    sin = 1; // idle = 1
    @(negedge clk);
    rst_n = 1;
  endtask

   function test_t get_test();
    bit [2:0] op_choice;
    op_choice = 3'($random);
    case (op_choice)
        3'b000 : return PROPER_FRAME;
        3'b001 : return WRONG_START_BIT;
        3'b010 : return WRONG_PARITY_BIT;
        3'b011 : return WRONG_STOP_BIT;
        3'b100 : return WRONG_START_PARITY_STOP;
        3'b101 : return RESET;
        3'b110 : return PROPER_FRAME;
        3'b111 : return WRONG_START_BIT;
    endcase // case (op_choice)
  endfunction : get_test

endinterface