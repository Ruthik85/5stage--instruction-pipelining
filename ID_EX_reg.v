module ID_EX_reg (
    input clk,
    input reset,
    
    // Inputs from Decode Stage
    input [31:0] reg_data1_in,
    input [31:0] reg_data2_in,
    input [31:0] imm_ext_in,
    input [4:0]  rd_in,
    input [3:0]  alu_control_in,
    input        alu_src_in,
    input        reg_write_in,
    input        mem_to_reg_in,   // ADDED FOR 5-STAGE
    input        mem_read_in,     // ADDED FOR 5-STAGE
    input        mem_write_in,    // ADDED FOR 5-STAGE
    
    // Outputs to Execute Stage
    output reg [31:0] reg_data1_out,
    output reg [31:0] reg_data2_out,
    output reg [31:0] imm_ext_out,
    output reg [4:0]  rd_out,
    output reg [3:0]  alu_control_out,
    output reg        alu_src_out,
    output reg        reg_write_out,
    output reg        mem_to_reg_out,  // ADDED FOR 5-STAGE
    output reg        mem_read_out,    // ADDED FOR 5-STAGE
    output reg        mem_write_out    // ADDED FOR 5-STAGE
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data1_out   <= 32'b0;
            reg_data2_out   <= 32'b0;
            imm_ext_out     <= 32'b0;
            rd_out          <= 5'b0;
            alu_control_out <= 4'b0;
            alu_src_out     <= 1'b0;
            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
        end else begin
            reg_data1_out   <= reg_data1_in;
            reg_data2_out   <= reg_data2_in;
            imm_ext_out     <= imm_ext_in;
            rd_out          <= rd_in;
            alu_control_out <= alu_control_in;
            alu_src_out     <= alu_src_in;
            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
        end
    end
endmodule