`timescale 1ns / 1ps

module tb_risc_v();
    reg clk;
    reg reset;

    // Instantiate your Top-Level Design
    risc_v_top uut (
        .clk(clk),
        .reset(reset)
    );

    // Generate a 100MHz clock
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize
        clk = 0;
        reset = 1;
        
        // 2. Release Reset after 2 cycles
        #20 reset = 0;
        
        // 3. Let it run for 10 instructions
        #100;
        
        $display("Simulation complete. Check the Waveform window.");
        $stop;
    end
endmodule

