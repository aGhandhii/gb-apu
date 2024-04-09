/* Testbench for Sweep Function

*/
module gb_sweepFunction_tb();

    // IO Replication
    logic clk;
    logic clk_sweep;
    logic trigger;
    logic [2:0] sweep_pace;
    logic sweep_decreasing;
    logic [2:0] num_sweep_shifts;
    logic [10:0] frequency;
    logic overflow;
    logic [10:0] shadow_frequency;

    // Toggle the Clock
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // Instance
    gb_sweepFunction dut (.*);

    // Tasks
    task triggerChannel();
        trigger = 1'b1;
        repeat (2) @(posedge clk);
        trigger = 1'b0;
    endtask

    task tickSweepClock();
        clk_sweep = 1'b1;
        @(posedge clk);
        clk_sweep = 1'b0;
    endtask

    task sweepSettings(logic [2:0] pace, logic decr, logic [2:0] sweepShamt, logic [10:0] freq);
        sweep_pace = pace;
        sweep_decreasing = decr;
        num_sweep_shifts = sweepShamt;
        frequency = freq;
    endtask

    // Testbench
    initial begin

        sweepSettings(
            .pace(3'b001),
            .decr(1'b1),
            .sweepShamt(3'b010),
            .freq(11'b00001000000)
        );
        triggerChannel();
        repeat(100) tickSweepClock();

        $stop();
    end


endmodule  // gb_sweepFunction_tb
