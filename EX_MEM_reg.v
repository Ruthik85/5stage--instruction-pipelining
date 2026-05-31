module EX_MEM_reg (
    input clk,
    input reset,
    
    // Inputs from Execute Stage
    input [31:0] alu_result_in,
    input [31:0] reg_data2_in,   // Needed for Store instructions (sw)
    input [4:0]  rd_in,
    input        reg_write_in,
    input        mem_to_reg_in,  // Control signal for choosing load data vs ALU data
    input        mem_read_in,
    input        mem_write_in,
    
    // Outputs to Memory Stage
    output reg [31:0] alu_result_out,
    output reg [31:0] reg_data2_out,
    output reg [4:0]  rd_out,
    output reg        reg_write_out,
    output reg        mem_to_reg_out,
    output reg        mem_read_out,
    output reg        mem_write_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_result_out <= 32'b0;
            reg_data2_out  <= 32'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_to_reg_out <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
        end else begin
            alu_result_out <= alu_result_in;
            reg_data2_out  <= reg_data2_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
        end
    end
endmodule
