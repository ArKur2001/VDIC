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
class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
    protected typedef enum bit {
        START_B_OK,
        START_B_ERR
      }start_bit_set_t;
      
      protected typedef enum bit {
        PARITY_B_OK,
        PARITY_B_ERR
      }parity_bit_set_t;
      
      protected typedef enum bit {
        STOP_B_OK,
        STOP_B_ERR
      }stop_bit_set_t;
      
      protected typedef enum bit {
        NO_RST,
        RST
      }reset_set_t;
      
      protected typedef enum bit {
        OK,
        ERR
      }frame_status_t;

      local frame_data_t frame_data [];
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// get random 
//------------------------------------------------------------------------------
    local function byte get_random();
        return $random & 'hFF;
      endfunction : get_random

//------------------------------------------------------------------------------
// reset routing array
//------------------------------------------------------------------------------
    protected function frame_data_array_t reset_routing_array();
        frame_status_t ret0;
        frame_status_t ret1;
    
        frame_data.delete;

        for(int i = 0 ; i <= 'hFF ; i++) begin
          ret0 = build_uart_msg (1, i & 'hFF, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
          ret1 = build_uart_msg (1, PORT_SOUT0, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
        end
    
        return frame_data;
    endfunction

//------------------------------------------------------------------------------
// uart message builder
//------------------------------------------------------------------------------
    local function frame_status_t build_uart_msg (input logic prog_mode, input byte data, start_bit_set_t start_set, parity_bit_set_t parity_set, stop_bit_set_t stop_set, reset_set_t reset_set);
        logic [10:0] buffer;
        logic reset_val;
        bit parity_bit;
        int array_size;
      
        case (start_set)
          START_B_OK: begin
            buffer[10] = 0;
          end
          START_B_ERR: begin
            buffer[10] = 1;
          end
          default: begin
            buffer[10] = 1;
          end
        endcase
      
        for (int i = 0 ; i <8 ; i++)begin
          buffer[9 - i] = data[i];
        end
      
        case (parity_set)
          PARITY_B_OK: begin
            parity_bit = ^data;
            buffer[1] = parity_bit;
          end
          PARITY_B_ERR: begin
            parity_bit = ~^data;
            buffer[1] = parity_bit;
          end
          default: begin
            parity_bit = ^data;
            buffer[1] = parity_bit;
          end
        endcase
      
        case (stop_set)
          STOP_B_OK: begin
            buffer[0] = 1;
          end
          STOP_B_ERR: begin
            buffer[0] = 0;
          end
          default: begin
            buffer[10] = 1;
          end
        endcase
      
        case (reset_set)
          RST: begin
            reset_val = 1;
          end
          NO_RST: begin
            reset_val = 0;
          end
          default: begin
            reset_val = 0;
          end
        endcase
    
        array_size = frame_data.size();
        frame_data = new[array_size + 1](frame_data);
        frame_data[array_size].reset = reset_val;
        frame_data[array_size].prog_mode = prog_mode;
        frame_data[array_size].input_message = buffer;
      
        if (start_set == START_B_ERR || parity_set == PARITY_B_ERR || stop_set == STOP_B_ERR || reset_set == RST) begin
          return ERR;
        end
        else begin
          return OK;
        end
      endfunction

//------------------------------------------------------------------------------
// random test for the tpgen generator
//------------------------------------------------------------------------------
    protected function test_t get_test();
        bit [2:0] op_choice;
        op_choice = 3'($random);
        case (op_choice)
            3'b000 : return PROPER_FRAME;
            3'b001 : return WRONG_START_BIT;
            3'b010 : return WRONG_PARITY_BIT;
            3'b011 : return WRONG_STOP_BIT;
            3'b100 : return WRONG_START_PARITY_STOP;
            3'b101 : return MIN_MAX_ADDR;
            3'b110 : return RESET;
            3'b111 : return PROPER_FRAME;
        endcase // case (op_choice)
      endfunction : get_test  

//------------------------------------------------------------------------------
// test sequences builder
//------------------------------------------------------------------------------
    protected function frame_data_array_t build_test_sequence(input test_t test, output logic[7:0] exp_sout0_frames[], output logic[7:0] exp_sout1_frames[]);
        start_bit_set_t start_set; 
        parity_bit_set_t parity_set; 
        stop_bit_set_t stop_set; 
        reset_set_t reset_set;
    
        int array_size;
        bit addr_arr [0:'hFF];
        byte addr_val_arr [0:'hFF];
        byte addr;
        byte data;
        int index;
        frame_status_t ret0;
        frame_status_t ret1;
    
        case(test)
          PROPER_FRAME: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_OK; 
            reset_set = NO_RST;
          end
          WRONG_START_BIT: begin
            start_set = START_B_ERR;
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_OK; 
            reset_set = NO_RST;
          end
          WRONG_PARITY_BIT: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_ERR; 
            stop_set = STOP_B_OK; 
            reset_set = NO_RST;
          end
          WRONG_STOP_BIT: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_ERR; 
            reset_set = NO_RST;
          end
          WRONG_START_PARITY_STOP: begin
            start_set = START_B_ERR; 
            parity_set = PARITY_B_ERR; 
            stop_set = STOP_B_ERR; 
            reset_set = NO_RST;
          end
          MIN_MAX_ADDR: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_OK; 
            reset_set = NO_RST;
          end
          RESET: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_OK; 
            reset_set = RST;
          end
          default: begin
            start_set = START_B_OK; 
            parity_set = PARITY_B_OK; 
            stop_set = STOP_B_OK; 
            reset_set = NO_RST;
          end
        endcase
    
        frame_data.delete;

        if(test == MIN_MAX_ADDR) begin
          ret0 = build_uart_msg (1, 'h00, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
          ret1 = build_uart_msg (1, PORT_SOUT0, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);

          ret0 = build_uart_msg (1, 'hFF, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
          ret1 = build_uart_msg (1, PORT_SOUT1, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);

          addr_arr['h00] = 'b0;
          addr_arr['hFF] = 'b1;
          addr_val_arr['h00] = 'h00;
          addr_val_arr['hFF] = 'hFF;
        end
        else begin
          for(int i = 0 ; i <= 'hFF ; i++) begin
            addr_arr[i] = get_random() & 'b1;
            addr_val_arr[i] = i & 'hFF;
          end
        
          for(int j = 0 ; j <= 'hFF ; j++) begin
            if(addr_arr[j] == 0) begin
              ret0 = build_uart_msg (1, addr_val_arr[j], START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
              ret1 = build_uart_msg (1, PORT_SOUT0, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
            end
            else begin
              ret0 = build_uart_msg (1, addr_val_arr[j], START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
              ret1 = build_uart_msg (1, PORT_SOUT1, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
            end
          end
        end
        
        for(int k = 0 ; k <= 'h0F ; k++) begin
          addr = get_random();
      
          if(test == MIN_MAX_ADDR) begin
            if(addr & 'b1 == 1) begin
              addr = 'hFF;
            end
            else begin
              addr = 'h00;
            end
          end

          index = -1;
          for(int l = 'hFF ; l >= 0 ; l--) begin
            if(addr_val_arr[l] == addr)begin
              index = l;
              break;
            end
          end
          
          data = get_random();
          ret0 = build_uart_msg (0, addr, start_set, parity_set, stop_set, reset_set);
          ret1 = build_uart_msg (0, data, start_set, parity_set, stop_set, reset_set);
      
          if (ret0 == OK && ret1 == OK) begin
            if (index >= 0) begin
              if (addr_arr[index] == 0) begin
                array_size = exp_sout0_frames.size();
                exp_sout0_frames = new[array_size + 2](exp_sout0_frames);
                exp_sout0_frames[array_size] = addr;
                exp_sout0_frames[array_size + 1] = data;
              end
              else begin
                array_size = exp_sout1_frames.size();
                exp_sout1_frames = new[array_size + 2](exp_sout1_frames);
                exp_sout1_frames[array_size] = addr;
                exp_sout1_frames[array_size + 1] = data;
              end
            end
            else begin
              array_size = exp_sout0_frames.size();
              exp_sout0_frames = new[array_size + 2](exp_sout0_frames);
              exp_sout0_frames[array_size] = addr;
              exp_sout0_frames[array_size + 1] = data;
            end
          end
        end
    
        return frame_data;

      endfunction

endclass : random_tpgen






