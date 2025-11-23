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
virtual class base_tpgen extends uvm_component;

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function test_t get_test();
    pure virtual protected function frame_data_array_t build_test_sequence(input test_t test, output logic[7:0] exp_sout0_frames[], output logic[7:0] exp_sout1_frames[]);
    pure virtual protected function frame_data_array_t reset_routing_array();
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        command_s command;

        phase.raise_objection(this);

        repeat(100) begin:tpgen_main_blk

            command.test = get_test();
            command.reset_frame_data = reset_routing_array();
            command.frame_data = build_test_sequence(command.test, command.exp_sout0_frames, command.exp_sout1_frames);
       
            command_port.put(command);

        end : tpgen_main_blk

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
