class coverage;
    
    protected virtual simple_uart_switch_bfm bfm;
  
    protected frame_data_t frame_prev;
  
    covergroup op_cov;
  
      option.name = "cg_op_cov";
  
      coverpoint bfm.test {
          bins A1_all_test_sequences[] = {[PROPER_FRAME : RESET]};
      }
    endgroup
  
    covergroup input_frames_cov;
  
      option.name = "cg_input_frames_cov";
  
      coverpoint bfm.frame.input_message[9:2] {
          bins A1_all_input_frame_data_sequences[] = {[8'b0 : 8'b11111111]};
      }
  
      coverpoint bfm.frame.input_message[10] {
        bins A2_all_input_frame_start_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint bfm.frame.input_message[1] {
        bins A3_all_input_frame_parity_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint bfm.frame.input_message[0] {
        bins A4_all_input_frame_stop_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint bfm.frame.reset {
          bins A5_all_reset_sequences[] = {[0 : 1]};
      }
  
      coverpoint bfm.frame.prog_mode {
          bins A6_all_prog_mode_sequences[] = {[0 : 1]};
      }
    endgroup
  
    function new (virtual simple_uart_switch_bfm b);
        op_cov               = new();
        input_frames_cov     = new();
        bfm                  = b;
    endfunction : new

    task execute();
        forever begin : sampling_block
            @(posedge bfm.clk);
            if(bfm.frame != frame_prev) begin
                op_cov.sample();
                input_frames_cov.sample();
                if($get_coverage() == 100) break; 
            end
    
            frame_prev = bfm.frame; 

        end : sampling_block
    endtask : execute

endclass