module top;
    import uvm_pkg::*;
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

    initial begin
        uvm_config_db #(virtual simple_uart_switch_bfm)::set(null, "*", "bfm", bfm);
        run_test();
    end

endmodule : top


