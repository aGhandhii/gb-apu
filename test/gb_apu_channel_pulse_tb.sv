/* Testbench for Pulse Channel */
module gb_apu_channel_pulse_tb ();

    // IO
    logic reset;
    logic clk;
    logic clk_length_ctr;
    logic clk_vol_env;
    logic clk_sweep;
    logic [2:0] sweep_time;
    logic sweep_decreasing;
    logic [2:0] num_sweep_shifts;
    logic [1:0] wave_duty;
    logic [5:0] length;
    logic [3:0] initial_volume;
    logic envelope_increasing;
    logic [2:0] num_envelope_sweeps;
    logic start;
    logic single;
    logic [10:0] frequency;
    logic [3:0] level;
    logic enable;

    initial begin : ToggleClock
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end : ToggleClock

    // Instance
    gb_apu_channel_pulse dut (.*);

    task automatic trigger();
        start = 1'b0;
        @(posedge clk);
        #1;
        start = 1'b1;
        @(posedge clk);
        #1;
        start = 1'b0;
    endtask : trigger

    task automatic sysReset();
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
    endtask : sysReset

    task automatic tickLength();
        clk_length_ctr = 1'b1;
        @(posedge clk);
        #1;
        clk_length_ctr = 1'b0;
    endtask : tickLength

    task automatic tickEnvelope();
        clk_vol_env = 1'b1;
        @(posedge clk);
        #1;
        clk_vol_env = 1'b0;
    endtask : tickEnvelope

    task automatic tickSweep();
        clk_sweep = 1'b1;
        @(posedge clk);
        #1;
        clk_sweep = 1'b0;
    endtask : tickSweep

    task automatic tickAll();
        clk_length_ctr = 1'b1;
        clk_vol_env = 1'b1;
        clk_sweep = 1'b1;
        @(posedge clk);
        #1;
        clk_length_ctr = 1'b0;
        clk_vol_env = 1'b0;
        clk_sweep = 1'b0;
    endtask : tickAll

    initial begin : Testbench

        // Save simulation results
        $dumpfile("gb_apu_channel_pulse_tb.vcd");
        $dumpvars();

        // Length Function Settings
        single = 1'b1;  // enable
        length = 6'b000001;

        // Envelope Function Settings
        initial_volume = 4'b0001;
        envelope_increasing = 1'b1;
        num_envelope_sweeps = 3'b111;

        // Sweep Function Settings
        sweep_time = 3'b111;  // Pace
        sweep_decreasing = 1'b1;  // Direction
        num_sweep_shifts = 3'b111;  // Sweep shift amount
        frequency = 11'b11111111111;  // system frequency

        // Pulse Channel Settings
        wave_duty = 2'b10;  // duty cycle select

        sysReset();
        trigger();

        //repeat(100) @(posedge clk);
        //repeat(100) tickLength();
        //repeat(100) tickEnvelope();

        repeat (1000) begin
            tickAll();
            repeat (64) @(posedge clk);
        end
        //repeat(100) tickAll();

        $stop();
    end : Testbench

endmodule : gb_apu_channel_pulse_tb
