module control_unit (
    input [6:0] opcode,
    input [14:12] funct3,
    input [31:25] funct7,
    output reg [3:0] alu_control,
    output reg alu_src,         // Mux select line: 0 for Reg File, 1 for Immediate
    output reg reg_write_en,    // Enables writing back to the Reg File
    output reg mem_to_reg,      // 1 for Load instructions, 0 for ALU results
    output reg mem_read,        // Enables Data Memory read
    output reg mem_write        // Enables Data Memory write
);

    always @(*) begin
        // --- Default assignments to prevent latch synthesis ---
        alu_src      = 1'b0;
        reg_write_en = 1'b0;
        mem_to_reg   = 1'b0;
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        alu_control  = 4'b0010; // Default to ADD

        case (opcode)
            // --- R-type Instructions (e.g., ADD, SUB, AND, OR) ---
            7'h33: begin
                reg_write_en = 1'b1;
                alu_src      = 1'b0; // Use register data 2
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'h20) 
                            alu_control = 4'b0110; // SUB
                        else 
                            alu_control = 4'b0010; // ADD
                    end
                    3'b111: alu_control = 4'b0000; // AND
                    3'b110: alu_control = 4'b0001; // OR
                    3'b010: alu_control = 4'b0111; // SLT
                    default: alu_control = 4'b0010;
                endcase
            end

            // --- I-type Instructions (e.g., ADDI) ---
            7'h13: begin
                reg_write_en = 1'b1;
                alu_src      = 1'b1; // Use sign-extended immediate
                case (funct3)
                    3'b000: alu_control = 4'b0010; // ADDI
                    default: alu_control = 4'b0010;
                endcase
            end

            // --- Load Instructions (e.g., lw - Load Word) ---
            7'h03: begin
                reg_write_en = 1'b1;
                alu_src      = 1'b1; // Calculate memory address using Immediate
                mem_to_reg   = 1'b1; // Route memory data back to Reg File
                mem_read     = 1'b1; // Enable RAM read path
                alu_control  = 4'b0010; // ALU performs Base Addr + Offset
            end

            // --- Store Instructions (e.g., sw - Store Word) ---
            7'h23: begin
                reg_write_en = 1'b0; // Do not write to Reg File
                alu_src      = 1'b1; // Calculate memory address using Immediate
                mem_write    = 1'b1; // Enable RAM write path
                alu_control  = 4'b0010; // ALU performs Base Addr + Offset
            end
            
            default: begin
                alu_control  = 4'b0010;
                alu_src      = 1'b0;
                reg_write_en = 1'b0;
                mem_to_reg   = 1'b0;
                mem_read     = 1'b0;
                mem_write    = 1'b0;
            end
        endcase
    end
endmodule