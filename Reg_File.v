module Reg_File (
    input clk,
    input reset,
    input reg_write_en,          // From the WB stage
    input [4:0]  read_reg1,      // rs1 from ID stage
    input [4:0]  read_reg2,      // rs2 from ID stage
    input [4:0]  write_reg,      // rd from WB stage
    input [31:0] write_data,     // alu_result from WB stage
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers [31:0];
    integer i;

    // Asynchronous Read: Data is available immediately when the address changes
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];

    // Synchronous Write: Data is saved on the rising edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'b0;
        end else if (reg_write_en && write_reg != 0) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule

