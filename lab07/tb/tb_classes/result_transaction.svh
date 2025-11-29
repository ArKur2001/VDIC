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
class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    sout_data_t result;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------

    function void do_copy(uvm_object rhs);
        result_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h,rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        result = copied_transaction_h.result;
    endfunction : do_copy

    function string convert2string();
        string s;
        string tmp;
    
        s = "RESULT TRANSACTION:\n";
    
        // ============================
        // SOUT0 FRAMES
        // ============================
        s = {s, "SOUT0_FRAMES:\n"};
    
        if (result.sout0_frames.size() == 0)
            s = {s, "  <empty>\n"};
        else begin
            for (int i = 0; i < result.sout0_frames.size(); i++) begin
                tmp = $sformatf(
                    "  [%0d] 0x%02h\n",
                    i,
                    result.sout0_frames[i]
                );
                s = {s, tmp};
            end
        end
    
        // ============================
        // SOUT1 FRAMES
        // ============================
        s = {s, "\nSOUT1_FRAMES:\n"};
    
        if (result.sout1_frames.size() == 0)
            s = {s, "  <empty>\n"};
        else begin
            for (int i = 0; i < result.sout1_frames.size(); i++) begin
                tmp = $sformatf(
                    "  [%0d] 0x%02h\n",
                    i,
                    result.sout1_frames[i]
                );
                s = {s, tmp};
            end
        end
    
        return s;
    endfunction : convert2string
    
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        result_transaction RHS;
        bit same;

        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);

        $cast(RHS, rhs);

        if((result.sout0_frames.size() != RHS.result.sout0_frames.size()) || (result.sout1_frames.size() != RHS.result.sout1_frames.size())) begin
            same = 0;
        end
        else begin
            for(int i = 0 ; i < result.sout0_frames.size() ; i++) begin
                if(result.sout0_frames[i] != RHS.result.sout0_frames[i]) begin
                    same = 0;
                end
            end

            for(int i = 0 ; i < result.sout1_frames.size() ; i++) begin
                if(result.sout1_frames[i] != RHS.result.sout1_frames[i]) begin
                    same = 0;
                end
            end
        end
        
        return same;
    endfunction : do_compare



endclass : result_transaction
