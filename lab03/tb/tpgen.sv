module tpgen(simple_uart_switch_bfm bfm);
  import simple_uart_switch_tb_pkg::*;

  frame_data_t frame_data [];

  typedef enum bit {
    START_B_OK,
    START_B_ERR
  }start_bit_set_t;

  typedef enum bit {
    PARITY_B_OK,
    PARITY_B_ERR
  }parity_bit_set_t;

  typedef enum bit {
    STOP_B_OK,
    STOP_B_ERR
  }stop_bit_set_t;

  typedef enum bit {
    NO_RST,
    RST
  }reset_set_t;

  typedef enum bit {
    OK,
    ERR
  }frame_status_t;

  function byte get_random();
    return $random & 'hFF;
  endfunction : get_random

  task reset_arrays();
    bfm.exp_sout0_frames.delete;
    bfm.exp_sout1_frames.delete;
  endtask

  task reset_routing_array();
    frame_status_t ret0;
    frame_status_t ret1;

    for(int i = 0 ; i <= 'hFF ; i++) begin
      ret0 = build_uart_msg (1, i & 'hFF, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
      ret1 = build_uart_msg (1, PORT_SOUT0, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
    end

    transmit_data();
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask

  task proper_frame_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
      ret1 = build_uart_msg (0, data, START_B_OK, PARITY_B_OK, STOP_B_OK, NO_RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask
  
  task wrong_start_bit_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_ERR, PARITY_B_OK, STOP_B_OK, NO_RST);
      ret1 = build_uart_msg (0, data, START_B_ERR, PARITY_B_OK, STOP_B_OK, NO_RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();
  
    repeat(4 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask
  
  task wrong_parity_bit_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_OK, PARITY_B_ERR, STOP_B_OK, NO_RST);
      ret1 = build_uart_msg (0, data, START_B_OK, PARITY_B_ERR, STOP_B_OK, NO_RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask
  
  task wrong_stop_bit_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_OK, PARITY_B_OK, STOP_B_ERR, NO_RST);
      ret1 = build_uart_msg (0, data, START_B_OK, PARITY_B_OK, STOP_B_ERR, NO_RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask
  
  task wrong_start_parity_stop_bit_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_ERR, PARITY_B_ERR, STOP_B_ERR, NO_RST);
      ret1 = build_uart_msg (0, data, START_B_ERR, PARITY_B_ERR, STOP_B_ERR, NO_RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask
  
  task reset_test();
    int array_size;
    bit addr_arr [0:'hFF];
    byte addr_val_arr [0:'hFF];
    byte addr;
    byte data;
    int index;
    frame_status_t ret0;
    frame_status_t ret1;

    reset_arrays();
    bfm.reset_sw();
    reset_routing_array();
    bfm.reset_sw();
  
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
  
    for(int k = 0 ; k <= 'h0F ; k++) begin
      addr = get_random();
  
      index = -1;
      for(int l = 'hFF ; l >= 0 ; l--) begin
        if(addr_val_arr[l] == addr)begin
          index = l;
          break;
        end
      end
      
      data = get_random();
      ret0 = build_uart_msg (0, addr, START_B_OK, PARITY_B_OK, STOP_B_OK, RST);
      ret1 = build_uart_msg (0, data, START_B_OK, PARITY_B_OK, STOP_B_OK, RST);
  
      if (ret0 == OK && ret1 == OK) begin
        if (index >= 0) begin
          if (addr_arr[index] == 0) begin
            array_size = bfm.exp_sout0_frames.size();
            bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
            bfm.exp_sout0_frames[array_size] = addr;
            bfm.exp_sout0_frames[array_size + 1] = data;
          end
          else begin
            array_size = bfm.exp_sout1_frames.size();
            bfm.exp_sout1_frames = new[array_size + 2](bfm.exp_sout1_frames);
            bfm.exp_sout1_frames[array_size] = addr;
            bfm.exp_sout1_frames[array_size + 1] = data;
          end
        end
        else begin
          array_size = bfm.exp_sout0_frames.size();
          bfm.exp_sout0_frames = new[array_size + 2](bfm.exp_sout0_frames);
          bfm.exp_sout0_frames[array_size] = addr;
          bfm.exp_sout0_frames[array_size + 1] = data;
        end
      end
    end
  
    transmit_data();

    bfm.rst_n = '0;
    @(negedge bfm.clk);
    bfm.rst_n = '1;
  
    repeat(2 * FRAME_LENGTH * CLKS_PER_BIT)@(negedge bfm.clk);
  endtask

  function frame_status_t build_uart_msg (input logic prog_mode, input byte data, start_bit_set_t start_set, parity_bit_set_t parity_set, stop_bit_set_t stop_set, reset_set_t reset_set);
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
  
  task transmit_data();
    foreach(frame_data[i]) begin

      bfm.frame = frame_data[i];
      
      for (int j = 10; j >= 0 ; j--) begin
        if(frame_data[i].reset == 1)begin
          bfm.prog = frame_data[i].prog_mode;
          bfm.sin = frame_data[i].input_message[j];
          bfm.rst_n = '0;
          @(negedge bfm.clk);
          bfm.rst_n = '1;
          repeat(CLKS_PER_BIT-1)@(negedge bfm.clk);
          end
        else begin
          bfm.prog = frame_data[i].prog_mode;
          bfm.sin = frame_data[i].input_message[j];
          repeat(CLKS_PER_BIT)@(negedge bfm.clk);
        end
      end
    end
    frame_data.delete;
  endtask


  initial begin : tpgen
    bfm.reset_sw();

      repeat(1000) begin:tpgen_main_blk
        @(negedge bfm.clk);

        bfm.test = bfm.get_test();
        bfm.test_end = TEST_IN_PROGRESS;

          case(bfm.test)
            PROPER_FRAME: begin
              proper_frame_test();
              bfm.test_end = TEST_END;
            end
            WRONG_START_BIT: begin
              wrong_start_bit_test();
              bfm.test_end = TEST_END;
            end
            WRONG_PARITY_BIT: begin
              wrong_parity_bit_test();
              bfm.test_end = TEST_END;
            end
            WRONG_STOP_BIT: begin
              wrong_stop_bit_test();
              bfm.test_end = TEST_END;
            end
            WRONG_START_PARITY_STOP: begin
              wrong_start_parity_stop_bit_test();
              bfm.test_end = TEST_END;
            end
            RESET: begin
              reset_test();
              bfm.test_end = TEST_END;
            end
            default: begin
              bfm.test = PROPER_FRAME;
            end
          endcase
        end : tpgen_main_blk
        $finish;
  end : tpgen

endmodule