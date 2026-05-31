module alu (
    input [31:0] a,          // From RegFile Read Data 1
    input [31:0] b,          // From RegFile Read Data 2 or Immediate
    input [3:0] alu_control, // From Decoder
    output reg [31:0] result,
    output zero              // High if result is 0 (used for Branches)
);
    assign zero = (result == 0);

    always @(*) begin
        case (alu_control)
            4'b0010: result = a + b;       // ADD
            4'b0110: result = a - b;       // SUB
            4'b0000: result = a & b;       // AND
            4'b0001: result = a | b;       // OR
            4'b0111: result = (a < b) ? 1 : 0; // Set Less Than (SLT)
            default: result = 32'b0;
        endcase
    end
endmodule

