package simple_uart_switch_tb_pkg;
 
    import uvm_pkg::*;
    `include "uvm_macros.svh"

  const int CLKS_PER_BIT = 16;
  const int FRAME_LENGTH = 11;
  const byte PORT_SOUT0 = 8'h00;
  const byte PORT_SOUT1 = 8'h01;

  typedef struct{
    logic reset;
    logic prog_mode;
    logic [10:0] input_message;
  } frame_data_t;

  typedef frame_data_t frame_data_array_t[];

  typedef enum logic[2:0] {
    PROPER_FRAME = 3'b000,
    WRONG_START_BIT = 3'b001,
    WRONG_PARITY_BIT = 3'b010,
    WRONG_STOP_BIT = 3'b011,
    WRONG_START_PARITY_STOP = 3'b100,
    RESET = 3'b111
  } test_t;

  typedef enum bit {
    TEST_IN_PROGRESS,
    TEST_END
  } test_end_t;

  typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
  } print_color_t;
  
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

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
`include "coverage.svh"
`include "scoreboard.svh"
`include "base_tpgen.svh"
`include "random_tpgen.svh"
`include "add_tpgen.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
`include "random_test.svh"
`include "add_test.svh"


endpackage