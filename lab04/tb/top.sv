module top;
    import simple_uart_switch_tb_pkg::*;

    simple_switch_uart DUT (
        .clk  (bfm.clk), 
        .prog (bfm.prog), 
        .rst_n(bfm.rst_n), 
        .sin  (bfm.sin), 
        .sout0(bfm.sout0), 
        .sout1(bfm.sout1) 
      );

    simple_uart_switch_bfm bfm();

    coverage coverage_i (bfm);

testbench testbench_h;

initial begin
    testbench_h = new(bfm);
    testbench_h.execute();
    $finish;
end

endmodule : top


