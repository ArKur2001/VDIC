module coverage(simple_uart_switch_bfm bfm);
  import simple_uart_switch_tb_pkg::*;

  frame_data_t frame_prev;

  covergroup op_cov;

    option.name = "cg_op_cov";

    coverpoint bfm.test {
        bins A1_all_test_sequences[] = {[PROPER_FRAME : RESET]};
    }
  endgroup

  covergroup input_frames_cov;

    option.name = "cg_input_frames_cov";

    coverpoint bfm.frame.input_message {
        bins A1_all_input_frame_sequences[] = {[11'b0 : 11'b11111111111]};
    }

    coverpoint bfm.frame.reset {
        bins A2_all_reset_sequences[] = {[0 : 1]};
    }

    coverpoint bfm.frame.prog_mode {
        bins A3_all_prog_mode_sequences[] = {[0 : 1]};
    }
  endgroup

  op_cov  oc;
  input_frames_cov input_data_frames;

  initial begin : coverage
    oc = new();
    input_data_frames = new();
    forever begin : sample_cov
          @(posedge bfm.clk);
          if(bfm.frame != frame_prev) begin
            oc.sample();
              #1step;
              input_data_frames.sample();
              #1step;

              if($get_coverage() == 100) break; 
          end
          
          frame_prev = bfm.frame;    
      end
  end : coverage

endmodule