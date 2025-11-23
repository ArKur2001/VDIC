interface simple_uart_switch_bfm;
  import simple_uart_switch_tb_pkg::*;

  logic clk;    
  logic rst_n;  
  logic prog;   
  logic sin;    
  logic sout0;   
  logic sout1;

  frame_data_t reset_frame_data[];
  frame_data_t frame_data[];
  logic[7:0] exp_sout0_frames [];
  logic[7:0] exp_sout1_frames [];
  test_t test;

  test_end_t test_end;
  sout_data_t sout_data_result;

  command_monitor command_monitor_h;
  result_monitor result_monitor_h;

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

//------------------------------------------------------------------------------
// reset expected values arrays
//------------------------------------------------------------------------------
  function void reset_arrays();
    reset_frame_data.delete;
    frame_data.delete;
    exp_sout0_frames.delete;
    exp_sout1_frames.delete;
  endfunction

  task send_op(frame_data_t ireset_frame_data[], frame_data_t iframe_data[], logic[7:0] iexp_sout0_frames [], logic[7:0] iexp_sout1_frames [], test_t itest);

    reset_arrays();

    reset_frame_data = reset_frame_data;
    frame_data = iframe_data;
    exp_sout0_frames = iexp_sout0_frames;
    exp_sout1_frames = iexp_sout1_frames;
    test = itest;

    reset_sw();

    test_end = TEST_IN_PROGRESS;
    @(negedge clk);
    
    reset_sw();
    transmit_data(ireset_frame_data);
    reset_sw();

    transmit_data(iframe_data);

    //wait for scoreboard
    repeat(16 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge clk);
    
    test_end = TEST_END;
    
    repeat(16 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge clk);
  endtask

  always @(posedge clk) begin : op_monitor
    command_s command;
    if (test_end == TEST_END) begin 
      command.reset_frame_data = reset_frame_data;
      command.frame_data = frame_data;
      command.exp_sout0_frames = exp_sout0_frames;
      command.exp_sout1_frames = exp_sout1_frames;
      command.test = test;

      command_monitor_h.write_to_monitor(command);
      
    end 
end : op_monitor

initial begin : result_monitor_thread
  
  fork
    monitor_sout0();
    monitor_sout1();
  join

  forever begin

    static test_end_t test_end_prev = TEST_IN_PROGRESS;

    @(negedge clk) ;
      if(test_end == TEST_END) begin
          result_monitor_h.write_to_monitor(sout_data_result);

          sout_data_result.sout0_frames.delete;
          sout_data_result.sout1_frames.delete;
      end
    test_end_prev = test_end;
  end
end : result_monitor_thread

task monitor_sout0();
  logic[10:0] buffer;
  int array_size;

  forever begin
    @(negedge clk);

    if(sout0 == 0)begin
      repeat(CLKS_PER_BIT/2)@(negedge clk);
      for(int i = 0 ; i <= 9 ; i++) begin
        buffer[i] = sout0;
        repeat(CLKS_PER_BIT)@(negedge clk);
      end 

      array_size = sout_data_result.sout0_frames.size();
      sout_data_result.sout0_frames = new[array_size + 1](sout_data_result.sout0_frames);
      sout_data_result.sout0_frames[array_size] = buffer[8:1];
    end
  end
endtask

task monitor_sout1();
  logic[10:0] buffer;
  int array_size;

  forever begin
    @(negedge clk);

    if(sout1 == 0)begin
      repeat(CLKS_PER_BIT/2)@(negedge clk);
      for(int i = 0 ; i <= 9 ; i++) begin
        buffer[i] = sout1;
        repeat(CLKS_PER_BIT)@(negedge clk);
      end 

      array_size = sout_data_result.sout1_frames.size();
      sout_data_result.sout1_frames = new[array_size + 1](sout_data_result.sout1_frames);
      sout_data_result.sout1_frames[array_size] = buffer[8:1];
    end
  end
endtask

endinterface