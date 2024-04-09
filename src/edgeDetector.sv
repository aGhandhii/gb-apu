/* Edge Detection Unit

Credit:
    VerilogBoy: https://github.com/zephray/VerilogBoy
*/
module edgeDetector (
    input logic clk,
    input logic i,
    output logic o
);

    logic last_i;
    always_ff @(posedge clk) begin
        last_i <= i;
    end

    // latch for first clock high after a positive edge, essentially delay
    // the posedge for an extra cycle
    assign o = (!last_i) && i;

endmodule // edgeDetector
