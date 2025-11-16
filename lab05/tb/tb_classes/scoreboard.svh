class scoreboard extends uvm_component;
  `uvm_component_utils(scoreboard)

  protected virtual simple_uart_switch_bfm bfm;

  protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
  } test_result_t;

  local logic[7:0] sout0_frames [];
  local logic[7:0] sout1_frames [];

  local int proper_frame_ok = 0;
  local int proper_frame_err = 0;

  local int wrong_start_bit_ok = 0;
  local int wrong_start_bit_err = 0;

  local int wrong_parity_bit_ok = 0;
  local int wrong_parity_bit_err = 0;

  local int wrong_stop_bit_ok = 0;
  local int wrong_stop_bit_err = 0;

  local int wrong_start_parity_stop_ok = 0;
  local int wrong_start_parity_stop_err = 0;

  local int reset_ok = 0;
  local int reset_err = 0;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 

  local function void reset_arrays();
    sout0_frames.delete;
    sout1_frames.delete;
  endfunction

  local function void print_scoreboard();
    $display("TEST_PROPER_FRAME: %0d passed, %0d errors.\n", proper_frame_ok, proper_frame_err);
    if(proper_frame_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end

    $display("TEST_WRONG_START_BIT: %0d passed, %0d errors.\n", wrong_start_bit_ok, wrong_start_bit_err);
    if(wrong_start_bit_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED (This error is expected. If appear, everything works OK ) \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end

    $display("TEST_WRONG_PARITY_BIT: %0d passed, %0d errors.\n", wrong_parity_bit_ok, wrong_parity_bit_err);
    if(wrong_parity_bit_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end

    $display("TEST_WRONG_STOP_BIT: %0d passed, %0d errors.\n", wrong_stop_bit_ok, wrong_stop_bit_err);
    if(wrong_stop_bit_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end

    $display("TEST_WRONG_START_PARITY_STOP_BIT: %0d passed, %0d errors.\n", wrong_start_parity_stop_ok, wrong_start_parity_stop_err);
    if(wrong_start_parity_stop_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED (This error is expected. If appear, everything works OK ) \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end

    $display("TEST_RESET: %0d passed, %0d errors.\n", reset_ok, reset_err);
    if(reset_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED \n");
      print_test_result(TEST_FAILED);
    end
    else begin
      print_test_result(TEST_PASSED);
    end
  endfunction

  local function void get_test_result();
    automatic bit match = 1;
    if (sout0_frames.size() != bfm.exp_sout0_frames.size()) match = 0;
    else begin
      for (int i = 0; i < sout0_frames.size(); i++) begin
        if (sout0_frames[i] !== bfm.exp_sout0_frames[i]) match = 0;
      end
    end
  
    if (sout1_frames.size() != bfm.exp_sout1_frames.size()) match = 0;
    else begin
      for (int i = 0; i < sout1_frames.size(); i++) begin
        if (sout1_frames[i] !== bfm.exp_sout1_frames[i]) match = 0;
      end
    end
  
    case(bfm.test)
      PROPER_FRAME: begin
        if(!match) begin
          proper_frame_err++;
        end
        else begin
          proper_frame_ok++;
        end
      end
      WRONG_START_BIT: begin
        if(!match) begin
          wrong_start_bit_err++;
        end
        else begin
          wrong_start_bit_ok++;
        end
      end
      WRONG_PARITY_BIT: begin
        if(!match) begin
          wrong_parity_bit_err++;
        end
        else begin
          wrong_parity_bit_ok++;
        end
      end
      WRONG_STOP_BIT: begin
        if(!match) begin
          wrong_stop_bit_err++;
        end
        else begin
          wrong_stop_bit_ok++;
        end
      end
      WRONG_START_PARITY_STOP: begin
        if(!match) begin
          wrong_start_parity_stop_err++;
        end
        else begin
          wrong_start_parity_stop_ok++;
        end
      end
      RESET: begin
        if(!match) begin
          reset_err++;
        end
        else begin
          reset_ok++;
        end
      end
      default: begin
      end
    endcase
  endfunction

  //------------------------------------------------------------------------------
  // Other functions
  //------------------------------------------------------------------------------
  
  protected function void print_test_result (test_result_t r);
      if(r == TEST_PASSED) begin
          set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
          $write ("-----------------------------------\n");
          $write ("----------- Test PASSED -----------\n");
          $write ("-----------------------------------");
          set_print_color(COLOR_DEFAULT);
          $write ("\n");
      end
      else begin
          set_print_color(COLOR_BOLD_BLACK_ON_RED);
          $write ("-----------------------------------\n");
          $write ("----------- Test FAILED -----------\n");
          $write ("-----------------------------------");
          set_print_color(COLOR_DEFAULT);
          $write ("\n");
      end
  endfunction

  protected task do_scoreboard();
    forever begin:scoreboard_fe_blk
      @(posedge bfm.clk);
        if(bfm.test_end == TEST_END) begin
          get_test_result();
          reset_arrays();
        end
    end
  endtask

  protected task monitor_sout0();
    logic[10:0] buffer;
    int array_size;
  
    forever begin
      @(negedge bfm.clk);
  
      if(bfm.sout0 == 0)begin
        repeat(CLKS_PER_BIT/2)@(negedge bfm.clk);
        for(int i = 0 ; i <= 9 ; i++) begin
          buffer[i] = bfm.sout0;
          repeat(CLKS_PER_BIT)@(negedge bfm.clk);
        end 
  
        array_size = sout0_frames.size();
        sout0_frames = new[array_size + 1](sout0_frames);
        sout0_frames[array_size] = buffer[8:1];
      end
    end
  endtask

  protected task monitor_sout1();
    logic[10:0] buffer;
    int array_size;
  
    forever begin
      @(negedge bfm.clk);
  
      if(bfm.sout1 == 0)begin
        repeat(CLKS_PER_BIT/2)@(negedge bfm.clk);
        for(int i = 0 ; i <= 9 ; i++) begin
          buffer[i] = bfm.sout1;
          repeat(CLKS_PER_BIT)@(negedge bfm.clk);
        end 
  
        array_size = sout1_frames.size();
        sout1_frames = new[array_size + 1](sout1_frames);
        sout1_frames[array_size] = buffer[8:1];
      end
    end
  endtask

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual simple_uart_switch_bfm)::get(null, "*","bfm", bfm))
        $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
      fork
          do_scoreboard();
          monitor_sout0();
          monitor_sout1();
      join_none
  endtask : run_phase

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      print_scoreboard();
  endfunction : report_phase
  
endclass