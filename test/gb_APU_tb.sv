/* Top-Level APU Testbench */
module gb_APU_tb();

    // IO Replication
    logic clk;
    logic reset;
    logic [15:0] addr_i;
    logic [7:0] data_i;
    logic wren;
    logic [7:0] data_o;
    logic [15:0] left;
    logic [15:0] right;

    // Instance
    gb_APU dut (.*);

    // Clock Toggle
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // Tasks
    task sysReset();
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
    endtask

    // Testbench
    initial begin
        sysReset();
        repeat(4194304) @(posedge clk);
        $stop();
    end

endmodule  // gb_APU_tb
