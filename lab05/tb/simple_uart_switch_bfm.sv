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

  task transmit_data(frame_data_t frame_data []);

    foreach(frame_data[i]) begin

      frame = frame_data[i];
      
      for (int j = 10; j >= 0 ; j--) begin
        if(frame_data[i].reset == 1)begin
          prog = frame_data[i].prog_mode;
          sin = frame_data[i].input_message[j];
          rst_n = '0;
          @(negedge clk);
          rst_n = '1;
          repeat(CLKS_PER_BIT-1)@(negedge clk);
          @(negedge clk);
          rst_n = '0;
          @(negedge clk);
          rst_n = '1;
        end
        else begin
          prog = frame_data[i].prog_mode;
          sin = frame_data[i].input_message[j];
          repeat(CLKS_PER_BIT)@(negedge clk);
        end
      end
    end

    repeat(4 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge clk);

  endtask

endinterface