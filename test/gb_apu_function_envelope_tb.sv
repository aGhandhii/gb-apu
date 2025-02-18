/* Testbench for Envelope Function Module */
module gb_apu_function_envelope_tb ();

    // Replicate IO
    logic clk;
    logic clk_vol_env;
    logic start;
    logic [3:0] initial_volume;
    logic envelope_increasing;
    logic [2:0] num_envelope_sweeps;
    logic [3:0] target_vol;

    initial begin : ToggleClock
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end : ToggleClock

    // DUT Instance
    gb_apu_function_envelope dut (.*);

    task automatic triggerChannel();
        start = 1'b1;
        repeat (2) @(posedge clk);
        start = 1'b0;
    endtask : triggerChannel

    task automatic tickEnvelope();
        clk_vol_env = 1'b1;
        @(posedge clk);
        #1;  // Time for logic resolution
        clk_vol_env = 1'b0;
        $display("Output Volume %4b", target_vol);
    endtask : tickEnvelope

    task automatic setEnvelopeSettings(logic [3:0] volInitial, logic isIncreasing, logic [2:0] numSweeps);
        initial_volume = volInitial;
        envelope_increasing = isIncreasing;
        num_envelope_sweeps = numSweeps;
    endtask : setEnvelopeSettings

    initial begin : Testbench

        // Save simulation results
        $dumpfile("gb_apu_function_envelope_tb.vcd");
        $dumpvars();

        setEnvelopeSettings(.volInitial(4'b0000), .isIncreasing(1'b1), .numSweeps(3'b001));
        triggerChannel();
        repeat (50) tickEnvelope();
        $stop();
    end : Testbench

endmodule : gb_apu_function_envelope_tb
