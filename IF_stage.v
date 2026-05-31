module IF_stage (
    input clk,
    input reset,
    output reg [31:0] PC,
    output [31:0] instr
);
    reg [31:0] instr_mem [0:255]; 
    integer i;

    initial begin
        // 1. Clear memory first to prevent 'X' values
        for (i = 0; i < 256; i = i + 1) begin
            instr_mem[i] = 32'b0;
        end
        // 2. Load the actual program
        $readmemh("instr.hex", instr_mem);
    end

    // Fetch Logic: Word aligned (Divide PC by 4)
    assign instr = instr_mem[PC[9:2]]; 

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'b0;
        else
            PC <= PC + 4; 
    end
endmodule

