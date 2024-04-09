/* Gameboy APU Noise Channel Module

Credit:
    https://nightshade256.github.io/2021/03/27/gb-sound-emulation.html
    VerilogBoy: https://github.com/zephray/VerilogBoy

Controls Channel 4, generates pseudorandom noise. The channel handles a 15-bit
LFSR and a Polynomial Counter Register, which acts as the main control for
updating the LFSR.

Inputs:
    reset               - System Reset
    clk                 - CPU Clock
    clk_length_ctr      - Length Control Clock
    clk_vol_env         - Volume Envelope Clock
    length              - Used for the Length Function
    initial_volume      - Starting volume, where 0 indicates no sound
    envelope_increasing - Direction of Envelope Function
    num_envelope_sweeps - Sweep Pace (envelope adjusts every 'sweep pace' 64Hz ticks)
    shift_clock_freq    - Shift Clock Prescaler
    counter_width       - LFSR Regulator
    freq_dividing_ratio - Period Divider shift amount
    start               - Channel Trigger
    single              - Stops sound once 'length' is reached

Outputs:
    level               - Channel Output
    enable              - Internal Enable Signal
*/
module gb_noiseChannel (
    input logic reset,
    input logic clk,
    input logic clk_length_ctr,
    input logic clk_vol_env,
    input logic [5:0] length,
    input logic [3:0] initial_volume,
    input logic envelope_increasing,
    input logic [2:0] num_envelope_sweeps,
    input logic [3:0] shift_clock_freq,
    input logic counter_width,
    input logic [2:0] freq_dividing_ratio,
    input logic start,
    input logic single,
    output logic [3:0] level,
    output logic enable
);

    // Posedge detect the trigger signal
    logic start_posedge;
    edgeDetector start_edgeDetection (
        .clk(clk),
        .i(start),
        .o(start_posedge)
    );

    /////////////////////////////////
    // POLYNOMIAL + LFSR REGISTERS //
    /////////////////////////////////

    /* The Polynomial Register is the Control Register for the LFSR.

    shift_clock_freq: the amount our divisor is shifted by
        -> We will call this 'Shift Amount'

    freq_dividing_ratio: the Base Divisor Code, encoded as follows:
        -> This calculation is determined by the formula:
            Divisor = (Value == 0) ? 8 : (Value << 4)

        Value | Divisor
        ---------------
        000   |   8
        001   |  16
        010   |  32
        011   |  48
        100   |  64
        101   |  80
        110   |  96
        111   | 112

    Given the previous values, we establish a formula for the Frequency Timer:
        Frequency Timer = Divisor << Shift Amount

    When the Frequency Timer expires, the following occurs:
        -> The Frequency Timer is recalculated with the formula above
        -> The LFSR is updated
    */

    // In range 0-112, needs 7 bits
    logic [6:0] polynomialDivisor;

    // Calculate the Frequency Timer Divisor
    always_comb begin
        if (freq_dividing_ratio == 3'b000)
            polynomialDivisor = 7'd8;
        else
            polynomialDivisor = {freq_dividing_ratio, 4'b0000};
    end

    // polynomialDivisor can be shifted by up to (2^4)-1 = 15 times, so we need
    // (7+15) = 22 bits.
    // The Frequency Timer acts as a down-counter
    logic [21:0] frequencyTimer;

    // Stores the calculated Frequency Timer formula result
    logic [21:0] calcFrequencyTimer;
    assign calcFrequencyTimer = ({{15{1'b0}}, polynomialDivisor} << shift_clock_freq);

    // Store the LFSR Register
    logic [14:0] lfsr;

    // The channel amplitude, before applying Envelope and Length functions,
    // is the inverted bit at index 0 of the LFSR Register.
    logic target_freq_out;
    assign target_freq_out = ~lfsr[0];

    // Next-State Calculation for the LFSR
    // The next state calculates the xor of index 0 and 1, and shifts the
    // current LFSR right by 1, placing the xor calculation in index 14, and
    // if counter_width is specified, also placing the calculation in index 6.
    logic [14:0] lfsr_next;
    always_comb begin
        case (counter_width)
            0: lfsr_next = {(lfsr[0] ^ lfsr[1]), lfsr[14:1]};
            1: lfsr_next = {(lfsr[0] ^ lfsr[1]), lfsr[14:8], (lfsr[0] ^ lfsr[1]), lfsr[6:1]};
            default: lfsr_next = lfsr;
        endcase
    end

    // LFSR and Polynomial Register State Progression
    always_ff @(posedge clk) begin
        if (start_posedge) begin
            frequencyTimer <= calcFrequencyTimer;
            lfsr <= {15{1'b1}};
        end
        else begin
            if (frequencyTimer == 38'd0) begin
                frequencyTimer <= calcFrequencyTimer;
                lfsr <= lfsr_next;
            end
            else
                frequencyTimer <= frequencyTimer - 1;
        end
    end

    /////////////////////////////////
    // ENVELOPE + LENGTH FUNCTIONS //
    /////////////////////////////////

    logic [3:0] target_vol;  // Store Envelope Volume Out

    // Envelope Function
    gb_envelopeFunction envelopeFunction (
        .clk(clk),
        .clk_vol_env(clk_vol_env),
        .start(start_posedge),
        .initial_volume(initial_volume),
        .envelope_increasing(envelope_increasing),
        .num_envelope_sweeps(num_envelope_sweeps),
        .target_vol(target_vol)
    );

    // Length Function
    gb_lengthFunction #(6) lengthFunction (
        .clk(clk),
        .reset(reset),
        .clk_length_ctr(clk_length_ctr),
        .start(start_posedge),
        .single(single),
        .length(length),
        .enable(enable)
    );

    // Only output target volume if the Envelope and Length functions allow it
    assign level = (enable&target_freq_out) ? target_vol : 4'b0000;

endmodule  // gb_noiseChannel
