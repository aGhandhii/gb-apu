/*

Testbench for Envelope Function Module

*/
module gb_envelopeFunction_tb();

    // Replicate IO
    logic clk;
    logic clk_vol_env;
    logic start;
    logic [3:0] initial_volume;
    logic envelope_increasing;
    logic [2:0] num_envelope_sweeps;
    logic [3:0] target_vol;

    // Toggle the Clock
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // DUT Instance
    gb_envelopeFunction dut (.*);

    task triggerChannel();
        start = 1'b1;
        repeat (2) @(posedge clk);
        start = 1'b0;
    endtask

    task tickEnvelope();
        clk_vol_env = 1'b1;
        @(posedge clk);
        clk_vol_env = 1'b0;
        $display("Output Volume %4b", target_vol);
    endtask

    task setEnvelopeSettings (
        logic [3:0] volInitial,
        logic isIncreasing,
        logic [2:0] numSweeps
    );
        initial_volume = volInitial;
        envelope_increasing = isIncreasing;
        num_envelope_sweeps = numSweeps;
    endtask


    // Test
    initial begin
        setEnvelopeSettings(
            .volInitial(4'b0000),
            .isIncreasing(1'b1),
            .numSweeps(3'b001)
        );
        triggerChannel();
        repeat(50) tickEnvelope();
        $stop();
    end


endmodule  // gb_envelopeFunction_tb
