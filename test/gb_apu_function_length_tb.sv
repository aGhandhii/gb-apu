/* Testbench for the Length Function */
module gb_apu_function_length_tb ();

    localparam WIDTH = 6;

    // IO Replication
    logic clk;
    logic reset;
    logic clk_length_ctr;
    logic start;
    logic single;
    logic [WIDTH-1:0] length;
    logic enable;

    initial begin : ToggleClock
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end : ToggleClock

    // DUT Instance
    gb_apu_function_length #(WIDTH) dut (.*);

    // Tasks
    task automatic triggerChannel();
        start = 1'b1;
        repeat (2) @(posedge clk);
        start = 1'b0;
    endtask : triggerChannel

    task automatic resetChannel();
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
    endtask : resetChannel

    task automatic tickLengthClock();
        clk_length_ctr = 1'b1;
        @(posedge clk);
        #1;  // Give time for design to resolve logic
        clk_length_ctr = 1'b0;
        $display("%s", enable ? "Volume ON" : "Volume OFF");
    endtask : tickLengthClock

    initial begin : Testbench

        // Save simulation results
        $dumpfile("gb_apu_function_length_tb.vcd");
        $dumpvars();

        single = 1'b1;
        length = 6'b111100;  // 4 cycles till shutoff
        resetChannel();
        triggerChannel();
        repeat (10) tickLengthClock();
        $stop();
    end : Testbench

endmodule : gb_apu_function_length_tb
