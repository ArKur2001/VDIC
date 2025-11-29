/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual simple_uart_switch_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual simple_uart_switch_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        bfm.command_monitor_h = this;
        ap                    = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// access function for BMF
//------------------------------------------------------------------------------
    static command_transaction cmd;

    function void write_to_monitor(frame_data_t reset_frame_data[], frame_data_t frame_data[], logic[7:0] exp_sout0_frames [], logic[7:0] exp_sout1_frames [], test_t test);

        `uvm_info("COMMAND MONITOR",$sformatf("Frame_data: %2h \n exp_sout0_frames: %2h \n exp_sout1_frames: %2h \n test: %s \n", frame_data, exp_sout0_frames, exp_sout1_frames, test.name()), UVM_HIGH);
        cmd = new("cmd");
        cmd.reset_frame_data = reset_frame_data;
        cmd.frame_data = frame_data;
        cmd.exp_sout0_frames = exp_sout0_frames;
        cmd.exp_sout1_frames = exp_sout1_frames;
        cmd.test = test;
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor

