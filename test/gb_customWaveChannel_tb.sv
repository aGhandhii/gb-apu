/* Testbench for Custom Wave Channel (Ch 3) */
module gb_customWaveChannel_tb ();

    // IO Replication
    logic reset;
    logic clk;
    logic clk_length_ctr;
    logic [7:0] length;
    logic [1:0] volume;
    logic on;
    logic single;
    logic start;
    logic [10:0] frequency;
    logic [7:0] wave_data;
    logic [3:0] wave_addr;
    logic [3:0] level;
    logic enable;

    ////////////////////////////
    // CUSTOM WAVE EMULATION  //
    ////////////////////////////

    // 16-byte wave data
    logic [7:0] waveData [16];

    generate
        genvar i;
        for (i=0;i<16;i++) begin: fillWaveData
            assign waveData[i] = 8'b11110000;
        end
    endgenerate

    assign wave_data = waveData[wave_addr];

    // Clock Toggle
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // Tasks
    task tickLength();
        clk_length_ctr = 1'b1;
        @(posedge clk);
        clk_length_ctr = 1'b0;
    endtask

    task trigger();
        start = 1'b0;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
    endtask

    task sysRst();
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
    endtask

    // Instance
    gb_customWaveChannel dut(.*);


    // Testbench
    initial begin

        // Length Function
        length = 8'b11001000;
        single = 1'b1;

        // Settings
        frequency = 11'b11111111000;
        on = 1'b1;
        volume = 2'b11;

        sysRst();
        trigger();
        repeat (100) begin
            @(posedge clk);
            //tickLength();
        end

        $stop();
    end

endmodule  // gb_customWaveChannel_tb
