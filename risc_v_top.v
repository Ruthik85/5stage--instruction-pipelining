module risc_v_top (
    input clk,
    input reset
);
    // =========================================================================
    // STAGE 1: FETCH (IF)
    // =========================================================================
    wire [31:0] pc_val, if_instr;
    
    IF_stage fetch (
        .clk(clk), .reset(reset), .PC(pc_val), .instr(if_instr)
    );

    wire [31:0] id_instr;
    IF_ID_reg p_reg_if_id (
        .clk(clk), .reset(reset), .instr_in(if_instr), .instr_out(id_instr)
    );

    // =========================================================================
    // STAGE 2: DECODE (ID)
    // =========================================================================
    wire [3:0]  id_alu_control;
    wire        id_alu_src, id_reg_write, id_mem_to_reg, id_mem_read, id_mem_write;
    wire [31:0] rf_data1, rf_data2, id_imm_ext;
    
    // Wire connections for final loopback from Stage 5
    wire [31:0] wb_data;
    wire [4:0]  wb_reg_addr;
    wire        wb_reg_write_en;

    control_unit cu (
        .opcode(id_instr[6:0]), .funct3(id_instr[14:12]), .funct7(id_instr[31:25]),
        .alu_control(id_alu_control), .alu_src(id_alu_src), .reg_write_en(id_reg_write),
        .mem_to_reg(id_mem_to_reg), .mem_read(id_mem_read), .mem_write(id_mem_write)
    );

    Reg_File rf (
        .clk(clk), .reset(reset),
        .read_reg1(id_instr[19:15]), .read_reg2(id_instr[24:20]), 
        .write_reg(wb_reg_addr), .write_data(wb_data), .reg_write_en(wb_reg_write_en), 
        .read_data1(rf_data1), .read_data2(rf_data2)
    );

    assign id_imm_ext = {{20{id_instr[31]}}, id_instr[31:20]}; 

    // --- ID/EX Pipeline Register ---
    wire [31:0] ex_reg_data1, ex_reg_data2, ex_imm_ext;
    wire [4:0]  ex_rd;
    wire [3:0]  ex_alu_control;
    wire        ex_alu_src, ex_reg_write, ex_mem_to_reg, ex_mem_read, ex_mem_write;

    ID_EX_reg p_reg_id_ex (
        .clk(clk), .reset(reset),
        .reg_data1_in(rf_data1), .reg_data2_in(rf_data2), .imm_ext_in(id_imm_ext), .rd_in(id_instr[11:7]),
        .alu_control_in(id_alu_control), .alu_src_in(id_alu_src), .reg_write_in(id_reg_write),
        .mem_to_reg_in(id_mem_to_reg), .mem_read_in(id_mem_read), .mem_write_in(id_mem_write),
        
        .reg_data1_out(ex_reg_data1), .reg_data2_out(ex_reg_data2), .imm_ext_out(ex_imm_ext), .rd_out(ex_rd),
        .alu_control_out(ex_alu_control), .alu_src_out(ex_alu_src), .reg_write_out(ex_reg_write),
        .mem_to_reg_out(ex_mem_to_reg), .mem_read_out(ex_mem_read), .mem_write_out(ex_mem_write)
    );

    // =========================================================================
    // STAGE 3: EXECUTE (EX)
    // =========================================================================
    wire [31:0] alu_input_b, alu_out;
    assign alu_input_b = (ex_alu_src) ? ex_imm_ext : ex_reg_data2;


    // Create a dummy wire for the branch flag if you aren't using it yet
    wire alu_zero_flag; 

    alu execution_unit (
        .a(ex_reg_data1), 
        .b(alu_input_b), 
        .alu_control(ex_alu_control), 
        .result(alu_out),
        .zero(alu_zero_flag) // Connected to clear the vsim-2685 warning!
    );

    // --- NEW: EX/MEM Pipeline Register ---
    wire [31:0] mem_alu_result, mem_reg_data2;
    wire [4:0]  mem_rd;
    wire        mem_reg_write, mem_mem_to_reg, mem_mem_read, mem_mem_write;

    EX_MEM_reg p_reg_ex_mem (
        .clk(clk), .reset(reset),
        .alu_result_in(alu_out), .reg_data2_in(ex_reg_data2), .rd_in(ex_rd),
        .reg_write_in(ex_reg_write), .mem_to_reg_in(ex_mem_to_reg), .mem_read_in(ex_mem_read), .mem_write_in(ex_mem_write),
        
        .alu_result_out(mem_alu_result), .reg_data2_out(mem_reg_data2), .rd_out(mem_rd),
        .reg_write_out(mem_reg_write), .mem_to_reg_out(mem_mem_to_reg), .mem_read_out(mem_mem_read), .mem_write_out(mem_mem_write)
    );

    // =========================================================================
    // STAGE 4: MEMORY ACCESS (MEM)
    // =========================================================================
    // Note: If you are not implementing load/store instructions yet, 
    // the ALU data passes straight through this stage.
    wire [31:0] mem_read_data; 
    assign mem_read_data = 32'b0; // Placeholder until Data Memory module is ready

    // --- MEM/WB Pipeline Register ---
    wire [31:0] wb_alu_result, wb_mem_read_data;
    wire        wb_mem_to_reg;

    MEM_WB_reg p_reg_mem_wb (
        .clk(clk), .reset(reset),
        .alu_result_in(mem_alu_result), .read_data_in(mem_read_data), .rd_in(mem_rd),
        .reg_write_in(mem_reg_write), .mem_to_reg_in(mem_mem_to_reg),
        
        .alu_result_out(wb_alu_result), .read_data_out(wb_mem_read_data), .write_reg_out(wb_reg_addr),
        .reg_write_out(wb_reg_write_en), .mem_to_reg_out(wb_mem_to_reg)
    );

    // =========================================================================
    // STAGE 5: WRITE BACK (WB)
    // =========================================================================
    // Choose whether to write back the ALU output calculation or the Data Memory read value
    assign wb_data = (wb_mem_to_reg) ? wb_mem_read_data : wb_alu_result;

endmodule
