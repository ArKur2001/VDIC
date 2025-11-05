module scoreboard(simple_uart_switch_bfm bfm);
  import simple_uart_switch_tb_pkg::*;

  typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
  } test_result_t;

  typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
  } print_color_t;

  logic[7:0] sout0_frames [];
  logic[7:0] sout1_frames [];

  int proper_frame_ok = 0;
  int proper_frame_err = 0;

  int wrong_start_bit_ok = 0;
  int wrong_start_bit_err = 0;

  int wrong_parity_bit_ok = 0;
  int wrong_parity_bit_err = 0;

  int wrong_stop_bit_ok = 0;
  int wrong_stop_bit_err = 0;

  int wrong_start_parity_stop_ok = 0;
  int wrong_start_parity_stop_err = 0;

  int reset_ok = 0;
  int reset_err = 0;

  function void reset_arrays();
    sout0_frames.delete;
    sout1_frames.delete;
  endfunction

  function void print_scoreboard();
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

  function void get_test_result();
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
  
  // used to modify the color of the text printed on the terminal
  function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
  endfunction
  
  function void print_test_result (test_result_t r);
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

  always @(posedge bfm.clk) begin : scoreboard
    
      if(bfm.test_end == TEST_END) begin
        get_test_result();
        reset_arrays();
      end
      
  end : scoreboard

  initial begin : monitor_sout0
    
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
        
  end : monitor_sout0

  initial begin : monitor_sout1
    
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
        
  end : monitor_sout1

  final begin : finish_of_the_test
    print_scoreboard();
  end

endmodule