/* Testbench for Noise Channel */
module gb_noiseChannel_tb();

    // IO Replication
    logic reset;
    logic clk;
    logic clk_length_ctr;
    logic clk_vol_env;
    logic [5:0] length;
    logic [3:0] initial_volume;
    logic envelope_increasing;
    logic [2:0] num_envelope_sweeps;
    logic [3:0] shift_clock_freq;
    logic counter_width;
    logic [2:0] freq_dividing_ratio;
    logic start;
    logic single;
    logic [3:0] level;
    logic enable;

    // Clock Toggle
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // Instance
    gb_noiseChannel dut (.*);

    // Tasks
    task trigger();
        start = 1'b0;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
    endtask

    task sysReset();
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
    endtask

    task tickLength();
        clk_length_ctr = 1'b1;
        @(posedge clk);
        clk_length_ctr = 1'b0;
    endtask

    task tickEnvelope();
        clk_vol_env = 1'b1;
        @(posedge clk);
        clk_vol_env = 1'b0;
    endtask

    task tickLengthEnvelope();
        clk_length_ctr = 1'b1;
        clk_vol_env = 1'b1;
        @(posedge clk);
        clk_length_ctr = 1'b0;
        clk_vol_env = 1'b0;
    endtask

    // Testbench
    initial begin

        // Length Function Settings
        single = 1'b1;
        length = 6'b101000;

        // Envelope Function Settings
        initial_volume = 4'b0001;  // Max volume
        envelope_increasing = 1'b1;
        num_envelope_sweeps = 3'b001;

        // Noise Channel Settings
        shift_clock_freq = 4'b0000;
        counter_width = 0;  // xor last index
        freq_dividing_ratio = 3'b000;

        sysReset();
        trigger();
        repeat (150) @(posedge clk); // Run until output is 1

        // test functions
        //repeat(100) tickLength();
        //repeat(100) tickEnvelope();
        repeat(100) tickLengthEnvelope();

        $stop();
    end

endmodule  // gb_noiseChannel_tb
