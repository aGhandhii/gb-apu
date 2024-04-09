/* GameBoy APU Frame Sequencer

Generates clocks for the APU functions (Sweep, Envelope, Length)

Credit:
    https://nightshade256.github.io/2021/03/27/gb-sound-emulation.html

Inputs:
    clk             - Base System Clock (4194304 (2^22) Hz)
    reset           - System Reset

Outputs:
    length_clk      - Length Function Clock (256 (2^8) Hz)
    envelope_clk    - Envelope Function Clock (64 (2^6) Hz)
    sweep_clk       - Sweep Function Clock (128 (2^7) Hz)
*/
module gb_frameSequencer (
    input logic clk,
    input logic reset,
    output logic length_clk,
    output logic envelope_clk,
    output logic sweep_clk
);
    /* We need separate clocks for Sweep, Envelope, and Length

    Based on the input clock in T-Cycles (~4MHz, 2^22), our Frame Sequencer
    steps once for every 8192 (2^13) T-Cycles, and the remaining clocks tick in
    dividends of the frame sequencer as follows:

    Step   Length  Volume/Envelope   Sweep
    -----------------------------------------
    0      Clock       -             -
    1      -           -             -
    2      Clock       -             Clock
    3      -           -             -
    4      Clock       -             -
    5      -           -             -
    6      Clock       -             Clock
    7      -           Clock         -
    -----------------------------------------
    Rate   256 Hz      64 Hz         128 Hz


    To achieve our desired outputs and avoid the intermediate Frame Sequencer,
    we add 3 additional bits from the frame sequencer's 13 to an up-counter for
    a total of (13+3)=16 bits. Because our base clock is a power of 2 (2^22),
    we can easily divide the clock input to obtain our desired clocks. */

    // Up-Counter for division
    logic [15:0] div;
    always_ff @(posedge clk) begin
        if (reset)
            div <= 16'd0;
        else
            div <= div + 16'd1;
    end

    // Output Clock Assignments
    assign length_clk   = (div[13:0] == {14{1'b1}});  // 2^(22-14) = 256
    assign envelope_clk = (div[15:0] == {16{1'b1}});  // 2^(22-16) = 64
    assign sweep_clk    = (div[14:0] == {15{1'b1}});  // 2^(22-15) = 128

endmodule  // gb_frameSequencer
