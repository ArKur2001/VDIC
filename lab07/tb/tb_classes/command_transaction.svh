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
class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    frame_data_t reset_frame_data[];
    frame_data_t frame_data[];
    logic[7:0] exp_sout0_frames [];
    logic[7:0] exp_sout1_frames [];
    rand test_t test;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

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

      local frame_data_t frame_data_buf[];

//------------------------------------------------------------------------------
// get random 
//------------------------------------------------------------------------------
      local function byte get_random();
        return $random & 'hFF;
      endfunction : get_random


//------------------------------------------------------------------------------
// reset routing array
//------------------------------------------------------------------------------
      local function frame_data_array_t reset_routing_array();
        frame_status_t ret0;
        frame_status_t ret1;
    
        frame_data_buf.delete;

        for(int i = 0 ; i <= 'hFF ; i++) begin
          ret0 = build_uart_msg (1, i & 'hFF, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
          ret1 = build_uart_msg (1, PORT_SOUT0, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
        end
    
        return frame_data_buf;
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
    
        array_size = frame_data_buf.size();
        frame_data_buf = new[array_size + 1](frame_data_buf);
        frame_data_buf[array_size].reset = reset_val;
        frame_data_buf[array_size].prog_mode = prog_mode;
        frame_data_buf[array_size].input_message = buffer;
      
        if (start_set == START_B_ERR || parity_set == PARITY_B_ERR || stop_set == STOP_B_ERR || reset_set == RST) begin
          return ERR;
        end
        else begin
          return OK;
        end
      endfunction

//------------------------------------------------------------------------------
// test sequences builder
//------------------------------------------------------------------------------
      local function frame_data_array_t build_test_sequence(input test_t test, output logic[7:0] exp_sout0_frames[], output logic[7:0] exp_sout1_frames[]);
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
    
        frame_data_buf.delete;

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
    
        return frame_data_buf;

      endfunction

//------------------------------------------------------------------------------
// post randomize actions
//------------------------------------------------------------------------------

    function void post_randomize();
        reset_frame_data = reset_routing_array();
        frame_data = build_test_sequence(test, exp_sout0_frames, exp_sout1_frames);
    endfunction

//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        command_transaction copied_transaction_h;

        if(rhs == null)
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

        super.do_copy(rhs); // copy all parent class data

        if(!$cast(copied_transaction_h,rhs))
            `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

        reset_frame_data = copied_transaction_h.reset_frame_data;
        frame_data = copied_transaction_h.frame_data;
        exp_sout0_frames = copied_transaction_h.exp_sout0_frames;
        exp_sout1_frames = copied_transaction_h.exp_sout1_frames;
        test = copied_transaction_h.test;

    endfunction : do_copy


    function command_transaction clone_me();
        
        command_transaction clone;
        uvm_object tmp;

        tmp = this.clone();
        $cast(clone, tmp);
        return clone;
        
    endfunction : clone_me


    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        
        command_transaction compared_transaction_h;
        bit same;

        if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
                "Tried to do comparison to a null pointer");

        if (!$cast(compared_transaction_h,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (compared_transaction_h.reset_frame_data == reset_frame_data) &&
            (compared_transaction_h.frame_data == frame_data) &&
            (compared_transaction_h.exp_sout0_frames == exp_sout0_frames) &&
            (compared_transaction_h.exp_sout1_frames == exp_sout1_frames) &&
            (compared_transaction_h.test == test);

        return same;
        
    endfunction : do_compare


    function string convert2string();
      string s;
      string tmp;
  
      // ============================
      // FRAME DATA
      // ============================
      s = "FRAME DATA:\n";
  
      if (frame_data.size() == 0)
          s = {s, "  <empty>\n"};
      else begin
          for (int i = 0; i < frame_data.size(); i++) begin
              tmp = $sformatf(
                  "  [%0d] reset=%0b prog_mode=%0b input_message=0x%0h\n",
                  i,
                  frame_data[i].reset,
                  frame_data[i].prog_mode,
                  frame_data[i].input_message
              );
              s = {s, tmp};
          end
      end
  
      // ============================
      // EXP SOUT0
      // ============================
      s = {s, "\nEXP_SOUT0_FRAMES:\n"};
  
      if (exp_sout0_frames.size() == 0)
          s = {s, "  <empty>\n"};
      else begin
          for (int i = 0; i < exp_sout0_frames.size(); i++) begin
              tmp = $sformatf(
                  "  [%0d] 0x%02h\n",
                  i,
                  exp_sout0_frames[i]
              );
              s = {s, tmp};
          end
      end
  
      // ============================
      // EXP SOUT1
      // ============================
      s = {s, "\nEXP_SOUT1_FRAMES:\n"};
  
      if (exp_sout1_frames.size() == 0)
          s = {s, "  <empty>\n"};
      else begin
          for (int i = 0; i < exp_sout1_frames.size(); i++) begin
              tmp = $sformatf(
                  "  [%0d] 0x%02h\n",
                  i,
                  exp_sout1_frames[i]
              );
              s = {s, tmp};
          end
      end
  
      // ============================
      // TEST TYPE
      // ============================
      s = { "\nTEST TYPE: ", s, test.name(), "\n"};
  
      return s;
  endfunction
  

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name = "");
        super.new(name);
    endfunction : new

endclass : command_transaction
