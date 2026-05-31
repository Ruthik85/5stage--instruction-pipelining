module MEM_WB_reg (
    input clk,
    input reset,
    
    // Inputs from Memory Stage (MEM)
    input [31:0] alu_result_in,
    input [31:0] read_data_in,     // Data read from Data Memory RAM
    input [4:0]  rd_in,            // Destination register address
    input        reg_write_in,     // Register File write enable
    input        mem_to_reg_in,    // Control signal to choose between ALU and Memory
    
    // Outputs to Write-Back Stage (WB)
    output reg [31:0] alu_result_out,
    output reg [31:0] read_data_out,
    output reg [4:0]  write_reg_out,   // Goes to rf.write_reg
    output reg        reg_write_out,   // Goes to rf.reg_write_en
    output reg        mem_to_reg_out   // Controls the final multiplexer Mux
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'b0;
            read_data_out  <= 32'b0;
            write_reg_out  <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            read_data_out  <= read_data_in;
            write_reg_out  <= rd_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
        end
    end
endmodule
