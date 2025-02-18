/* Top-Level APU Testbench */
module gb_apu_tb ();

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
    gb_apu dut (.*);

    initial begin : ClockToggle
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end : ClockToggle

    task automatic sysReset();
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
    endtask : sysReset

    initial begin : Testbench

        // Save simulation results
        $dumpfile("gb_apu_tb.vcd");
        $dumpvars();

        sysReset();
        repeat (4194304) begin
            @(posedge clk);
            #1;
        end
        $stop();
    end : Testbench

endmodule : gb_apu_tb
