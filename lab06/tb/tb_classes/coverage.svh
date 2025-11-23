class coverage extends uvm_subscriber #(command_s);
  `uvm_component_utils(coverage)
    
    protected frame_data_t frame;
    protected test_t test;
  
    covergroup op_cov;
  
      option.name = "cg_op_cov";
  
      coverpoint test {
          bins A1_all_test_sequences[] = {[PROPER_FRAME : RESET]};
      }
    endgroup
  
    covergroup input_frames_cov;
  
      option.name = "cg_input_frames_cov";
  
      coverpoint frame.input_message[9:2] {
          bins A1_all_input_frame_data_sequences[] = {[8'b0 : 8'b11111111]};
      }
  
      coverpoint frame.input_message[10] {
        bins A2_all_input_frame_start_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint frame.input_message[1] {
        bins A3_all_input_frame_parity_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint frame.input_message[0] {
        bins A4_all_input_frame_stop_bit_sequences[] = {[0 : 1]};
      } 
  
      coverpoint frame.reset {
          bins A5_all_reset_sequences[] = {[0 : 1]};
      }
  
      coverpoint frame.prog_mode {
          bins A6_all_prog_mode_sequences[] = {[0 : 1]};
      }
    endgroup
  
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
      super.new(name, parent);
      op_cov               = new();
      input_frames_cov     = new();
    endfunction : new

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    function void write(command_s t);
      test = t.test;
      op_cov.sample();

      foreach(t.frame_data[i]) begin
        frame = t.frame_data[i];
        input_frames_cov.sample();
      end
               
    endfunction : write

endclass