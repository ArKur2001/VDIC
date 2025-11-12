package simple_uart_switch_tb_pkg;

  const int CLKS_PER_BIT = 16;
  const int FRAME_LENGTH = 11;
  const byte PORT_SOUT0 = 8'h00;
  const byte PORT_SOUT1 = 8'h01;

  typedef struct{
    logic reset;
    logic prog_mode;
    logic [10:0] input_message;
  } frame_data_t;

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

  //`include "coverage.svh"
  `include "tpgen.svh"
  `include "scoreboard.svh"
  `include "testbench.svh"

endpackage