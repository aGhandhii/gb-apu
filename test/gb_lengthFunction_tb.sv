/*
Testbench for the Length Function
*/
module gb_lengthFunction_tb();

    localparam WIDTH = 6;


    // IO Replication
    logic clk;
    logic reset;
    logic clk_length_ctr;
    logic start;
    logic single;
    logic [WIDTH-1:0] length;
    logic enable;

    // Toggle the Clock
    initial begin
        clk = 1'b0;
        forever #(10) clk <= ~clk;
    end

    // DUT Instance
    gb_lengthFunction #(WIDTH) dut (.*);

    // Tasks
    task triggerChannel();
        start = 1'b1;
        repeat (2) @(posedge clk);
        start = 1'b0;
    endtask

    task resetChannel();
        reset = 1'b1;
        @(posedge clk);
        reset = 1'b0;
    endtask

    task tickLengthClock();
        clk_length_ctr = 1'b1;
        @(posedge clk);
        clk_length_ctr = 1'b0;
        $display("%s",
            enable ? "Volume ON" : "Volume OFF"
        );
    endtask

    // Testbench
    initial begin
        single = 1'b1;
        length = 6'b111100;  // 4 cycles till shutoff
        resetChannel();
        triggerChannel();
        repeat(10) tickLengthClock();
        $stop();
    end


endmodule  //gb_lengthFunction_tb
