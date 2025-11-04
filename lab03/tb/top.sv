module top;
  import simple_uart_switch_tb_pkg::*;

  simple_uart_switch_bfm bfm();
  tpgen tpgen_i (bfm);
  coverage coverage_i (bfm);
  scoreboard scoreboard_i(bfm);

  simple_switch_uart DUT (
    .clk  (bfm.clk), 
    .prog (bfm.prog), 
    .rst_n(bfm.rst_n), 
    .sin  (bfm.sin), 
    .sout0(bfm.sout0), 
    .sout1(bfm.sout1) 
  );

endmodule : top