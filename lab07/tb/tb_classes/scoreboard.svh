class scoreboard extends uvm_subscriber #(result_transaction);
  `uvm_component_utils(scoreboard)

  protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
  } test_result_t;

// virtual tinyalu_bfm bfm;
  uvm_tlm_analysis_fifo #(command_transaction) cmd_f;

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

  local int min_max_addr_ok = 0;
  local int min_max_addr_err = 0;

  local int reset_ok = 0;
  local int reset_err = 0;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 

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

    $display("TEST_MIN_MAX_ADDR: %0d passed, %0d errors.\n", min_max_addr_ok, min_max_addr_err);
    if(min_max_addr_err > 0)begin
      $display("UNEXPECTED FRAMES APPERAED \n");
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

  local function void get_test_result(sout_data_t sout_data, logic[7:0] exp_sout0_frames[], logic[7:0] exp_sout1_frames[], test_t test);
    automatic bit match = 1;
    if (sout_data.sout0_frames.size() != exp_sout0_frames.size()) match = 0;
    else begin
      for (int i = 0; i < sout_data.sout0_frames.size(); i++) begin
        if (sout_data.sout0_frames[i] != exp_sout0_frames[i]) match = 0;
      end
    end
  
    if (sout_data.sout1_frames.size() != exp_sout1_frames.size()) match = 0;
    else begin
      for (int i = 0; i < sout_data.sout1_frames.size(); i++) begin
        if (sout_data.sout1_frames[i] != exp_sout1_frames[i]) match = 0;
      end
    end
  
    case(test)
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
      MIN_MAX_ADDR: begin
        if(!match) begin
          min_max_addr_err++;
        end
        else begin
          min_max_addr_ok++;
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

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    cmd_f = new ("cmd_f", this);
  endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
  function void write(result_transaction t);
    command_transaction cmd;
    string data_str;

    if (!cmd_f.try_get(cmd))
      $fatal(1, "Missing command in self checker");
    
    get_test_result(t.result, cmd.exp_sout0_frames, cmd.exp_sout1_frames, cmd.test);

    //data_str  = {
    //" ==>  Actual " , t.convert2string(),
    //"/Predicted ", cmd.convert2string()};

    //if (!cmd.compare(t)) begin
    //    `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
    //end
    //else
    //    `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)

    endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      print_scoreboard();
  endfunction : report_phase
  
endclass