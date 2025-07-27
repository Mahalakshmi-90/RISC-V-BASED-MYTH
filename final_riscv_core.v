\m4_TLV_version 1d: tl-x.org
\SV
   // Modified version for custom RISC-V implementation
   
   m4_include_lib(['https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV

   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Test program for custom RV32I CPU
   // Adds numbers from 1 to 9 sequentially.
   //
   // Registers used:
   //  r10 (a0): Input 0, Output final sum
   //  r12 (a2): Value 10
   //  r13 (a3): Counter 1 to 10
   //  r14 (a4): Running sum
   // 
   // Setup outside function:
   m4_asm(ADD, r10, r0, r0)             // Set r10 (a0) to 0.
   // Function body:
   m4_asm(ADD, r14, r10, r0)            // Set sum register a4 to 0x0
   m4_asm(ADDI, r12, r10, 1010)         // Load 10 into register a2.
   m4_asm(ADD, r13, r10, r0)            // Set counter register a3 to 0
   // Loop section:
   m4_asm(ADD, r14, r13, r14)           // Add to sum
   m4_asm(ADDI, r13, r13, 1)            // Increment counter by 1
   m4_asm(BLT, r13, r12, 1111111111000) // Branch if a3 < a2 to loop
   m4_asm(ADD, r10, r14, r0)            // Copy sum to a0 for output
   
   // Memory test operations
   m4_asm(SW, r0, r10, 100) // Store result in memory
   m4_asm(LW, r15, r0, 100) // Load result back to r15
   
   // Optional infinite loop (commented):
   //m4_asm(JAL, r7, 00000000000000000000) // Jump to self
   
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)

   |cpu
      @0
         $reset = *reset;
         
         // Program counter logic
         $pc[31:0] = >>1$reset                     ? 32'd0 :
                     >>3$valid_taken_br            ? >>3$br_tgt_pc :
                     >>3$valid_load                ? >>1$inc_pc :
                     (>>3$valid_jump && >>3$is_jal)  ? >>3$br_tgt_pc :
                     (>>3$valid_jump && >>3$is_jalr) ? >>3$jalr_tgt_pc :
                     >>1$inc_pc;
         
         // Instruction memory access
         $imem_rd_en = !$reset;
         $imem_rd_addr[M4_IMEM_INDEX_CNT-1:0] = $pc[M4_IMEM_INDEX_CNT+1:2];
      
      @1
         $inc_pc[31:0] = $pc + 32'd4;
         $instr[31:0]  = $imem_rd_data;
         
         // Instruction type decoding
         $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                       $instr[6:2] ==? 5'b001x0 ||
                       $instr[6:2] ==? 5'b11001 || 
                       $instr[6:2] ==? 5'b11100;
         $is_r_instr = $instr[6:2] ==? 5'b011x0 ||
                       $instr[6:2] ==? 5'b01011 || 
                       $instr[6:2] ==? 5'b10100;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         $is_b_instr = $instr[6:2] ==  5'b11000;
         $is_j_instr = $instr[6:2] ==  5'b11011;
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         
         // Opcode extraction
         $opcode[6:0] = $instr[6:0];
         
         // Immediate value decoding
         $imm[31:0] = $is_i_instr ? { {21{$instr[31]}}, $instr[30:20] } :
                      $is_s_instr ? { {21{$instr[31]}}, $instr[30:25], $instr[11:7] } :
                      $is_b_instr ? { {20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0 } :
                      $is_u_instr ? { $instr[31:12], 12'd0 } :
                      $is_j_instr ? { $instr[31:12], $instr[20], $instr[30:21], 1'b0 } :
                                    32'd0;
         
         // Function field validity and extraction
         $funct7_valid = $is_r_instr;
         $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
         ?$funct3_valid
            $funct3[2:0] = $instr[14:12];
         
         // Register field validity and extraction
         $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         $rd_valid  = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
         
         ?$rs1_valid
            $rs1[4:0]    = $instr[19:15];
         ?$rs2_valid
            $rs2[4:0]    = $instr[24:20];
         ?$rd_valid
            $rd[4:0]     = $instr[11:7];
         
         $dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
         
         // RV32I instruction decoding
         $is_lui    = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc  = $dec_bits ==? 11'bx_xxx_0010111;
         $is_jal    = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalr   = $dec_bits ==? 11'bx_000_1100111;
         $is_jump   = $is_jal || $is_jalr;
         
         $is_beq    = $dec_bits ==? 11'bx_000_1100011;
         $is_bne    = $dec_bits ==? 11'bx_001_1100011;
         $is_blt    = $dec_bits ==? 11'bx_100_1100011;
         $is_bge    = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu   = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu   = $dec_bits ==? 11'bx_111_1100011;
         
         $is_lb     = $dec_bits ==? 11'bx_000_0000011;
         $is_lh     = $dec_bits ==? 11'bx_001_0000011;
         $is_lw     = $dec_bits ==? 11'bx_010_0000011;
         $is_lbu    = $dec_bits ==? 11'bx_100_0000011;
         $is_lhu    = $dec_bits ==? 11'bx_101_0000011;
         $is_load   = ($is_lb || $is_lh || $is_lw || $is_lbu || $is_lhu);
         
         $is_sb     = $dec_bits ==? 11'bx_000_0100011;
         $is_sh     = $dec_bits ==? 11'bx_001_0100011;
         $is_sw     = $dec_bits ==? 11'bx_010_0100011;
         
         $is_addi   = $dec_bits ==? 11'bx_000_0010011;
         $is_slti   = $dec_bits ==? 11'bx_010_0010011;
         $is_sltiu  = $dec_bits ==? 11'bx_011_0010011;
         $is_xori   = $dec_bits ==? 11'bx_100_0010011;
         $is_ori    = $dec_bits ==? 11'bx_110_0010011;
         $is_andi   = $dec_bits ==? 11'bx_111_0010011;
         $is_slli   = $dec_bits ==? 11'b0_001_0010011;
         $is_srli   = $dec_bits ==? 11'b0_101_0010011;
         $is_srai   = $dec_bits ==? 11'b1_101_0010011;
         
         $is_add    = $dec_bits ==? 11'b0_000_0110011;
         $is_sub    = $dec_bits ==? 11'b1_000_0010011;
         $is_sll    = $dec_bits ==? 11'b0_001_0010011;
         $is_slt    = $dec_bits ==? 11'b0_010_0010011;
         $is_sltu   = $dec_bits ==? 11'b0_011_0010011;
         $is_xor    = $dec_bits ==? 11'b0_100_0010011;
         $is_srl    = $dec_bits ==? 11'b0_101_0010011;
         $is_sra    = $dec_bits ==? 11'b1_101_0010011;
         $is_or     = $dec_bits ==? 11'b0_110_0010011;
         $is_and    = $dec_bits ==? 11'b0_111_0010011;

      @2
         // Register file read operations
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;

         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         
         // Branch target calculation
         $br_tgt_pc[31:0] = $pc + $imm;
         $jalr_tgt_pc[31:0] = $src1_value + $imm;
         
         // ALU input sources (handling RAW hazards)
         $src1_value[31:0] = (>>1$rf_wr_index == $rf_rd_index1) && >>1$rf_wr_en ?
                              >>1$rf_wr_data :
                                 $rf_rd_data1;
         $src2_value[31:0] = (>>1$rf_wr_index == $rf_rd_index2) && >>1$rf_wr_en ?
                              >>1$rf_wr_data :
                                 $rf_rd_data2;
      @3
         // ALU computation
         $result[31:0] = $is_lui     ? {$imm[31:12], 12'b0} :
                         $is_auipc   ? $pc + $imm :
                         $is_jal     ? $pc + 32'd4 :
                         $is_jalr    ? $pc + 32'd4 :
                         $is_load    ? $src1_value + $imm:
                         $is_s_instr ? $src1_value + $imm:
                         $is_addi    ? $src1_value + $imm:
                         $is_slti    ? (($src1_value[31] == $imm[31]) ? $sltiu_result : {31'b0, $src1_value[31]}) :
                         $is_sltiu   ? $sltiu_result:
                         $is_xori    ? $src1_value ^ $imm :
                         $is_ori     ? $src1_value | $imm :
                         $is_andi    ? $src1_value & $imm :
                         $is_slli    ? $src1_value << $imm[5:0] :
                         $is_srli    ? $src1_value >> $imm[5:0] :
                         $is_srai    ? {{32{$src1_value[31]}}, $src1_value} >> $imm[4:0] :
                         $is_add     ? $src1_value + $src2_value:
                         $is_sub     ? $src1_value - $src2_value :
                         $is_sll     ? $src1_value << $src2_value[4:0] :
                         $is_slt     ? (($src1_value[31] == $src2_value[31]) ? $sltu_result : {31'b0, $src1_value[31]}) :
                         $is_sltu    ? $sltu_result :
                         $is_xor     ? $src1_value ^ $src2_value :
                         $is_srl     ? $src1_value >> $src2_value[4:0] :
                         $is_sra     ? {{32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0] :
                         $is_or      ? $src1_value | $src2_value :
                         $is_and     ? $src1_value & $src2_value :
                         32'bx;
         
         $sltu_result[31:0]  = $src1_value < $src2_value;
         $sltiu_result[31:0] = $src1_value < $imm;
         
         $taken_br = $is_beq  ? ($src1_value == $src2_value) :
                     $is_bne  ? ($src1_value != $src2_value) :
                     $is_blt  ? (($src1_value < $src2_value)  ^ ($src1_value[31] != $src2_value[31])) :
                     $is_bge  ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
                     $is_bltu ? ($src1_value < $src2_value)  :
                     $is_bgeu ? ($src1_value >= $src2_value) :
                     1'b0;
         
         // Pipeline validity checks
         $valid = !(>>1$valid_taken_br || >>2$valid_taken_br || >>1$is_load || >>2$is_load || >>1$valid_jump || >>2$valid_jump);
         $valid_taken_br = $valid && $taken_br;
         $valid_load = $valid && $is_load;
         $valid_jump = $valid && $is_jump;
         
         // Register file write operations
         $rf_wr_en = ($valid && $rd_valid && ($rd != 5'b0)) || >>2$valid_load;
         $rf_wr_index[4:0] = >>2$valid_load ? >>2$rd : $rd;
         $rf_wr_data[31:0] = >>2$valid_load ? >>2$ld_data : $result;
         
      @4
         // Data memory interface
         $dmem_rd_en = $is_load;
         $dmem_wr_en = $valid && $is_s_instr;
         $dmem_addr[3:0]  = $result[5:2];
         $dmem_wr_data[31:0] = $src2_value;
      
      @5
         $ld_data[31:0] = $dmem_rd_data;
         
   *passed = |cpu/xreg[15]>>6$value == (1+2+3+4+5+6+7+8+9);
   // Simulation end assertions
   //*passed = *cyc_cnt > 100;
   *failed = 1'b0;
   
   // Macro instantiations for CPU components
   |cpu
      m4+imem(@1)    // Instruction memory (read stage)
      m4+rf(@2, @3)  // Register file (read/write stages)
      m4+dmem(@4)    // Data memory (read/write stage)

   m4+cpu_viz(@4)    // CPU visualization (stage >= last logic stage)
\SV
   endmodule
