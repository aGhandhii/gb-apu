/* Gameboy APU Pulse Channel Module

Credit:
    VerilogBoy: https://github.com/zephray/VerilogBoy

Controls Channels 1 and 2, generates a Pulse with additional Envelope, Sweep,
and Length Functions.

Inputs:
    reset               - System Reset
    clk                 - CPU Clock
    clk_length_ctr      - Length Control Clock
    clk_vol_env         - Volume Envelope Clock
    clk_sweep           - Sweep Clock
    sweep_time          - Pace of sweep operations
    sweep_decreasing    - Direction of Sweep Function (0 incr, 1 decr)
    num_sweep_shifts    - Amount frequency is shifted by in a sweep step
    wave_duty           - Duty Cycle (00=12.5% 01=25% 10=50% 11=75%)
    length              - Used for the Length Function
    initial_volume      - Starting volume, where 0 indicates no sound
    envelope_increasing - Direction of Envelope Function
    num_envelope_sweeps - Sweep Pace (envelope adjusts every 'sweep pace' 64Hz ticks)
    start               - Restart Audio
    single              - Stops sound once 'length' is reached
    frequency           - Period Value, where freq=131072/(2048-Period Value)

Outputs:
    level               - Channel Output
    enable              - Internal Enable Signal
*/
module gb_pulseChannel (
    input logic reset,
    input logic clk,
    input logic clk_length_ctr,
    input logic clk_vol_env,
    input logic clk_sweep,
    input logic [2:0] sweep_time,
    input logic sweep_decreasing,
    input logic [2:0] num_sweep_shifts,
    input logic [1:0] wave_duty,
    input logic [5:0] length,
    input logic [3:0] initial_volume,
    input logic envelope_increasing,
    input logic [2:0] num_envelope_sweeps,
    input logic start,
    input logic single,
    input logic [10:0] frequency,
    output logic [3:0] level,
    output logic enable
);

    // Detect the channel trigger signal
    logic start_posedge;
    edgeDetector start_edgeDetection (
        .clk(clk),
        .i(start),
        .o(start_posedge)
    );

    /////////////////////////////////////////////////
    // CHANNEL FUNCTIONS (SWEEP, ENVELOPE, LENGTH) //
    /////////////////////////////////////////////////

    logic overflow;
    logic [10:0] pulse_frequency;

    gb_sweepFunction sweepFuncion (
        .clk(clk),
        .clk_sweep(clk_sweep),
        .trigger(start_posedge),
        .sweep_pace(sweep_time),
        .sweep_decreasing(sweep_decreasing),
        .num_sweep_shifts(num_sweep_shifts),
        .frequency(frequency),
        .overflow(overflow),
        .shadow_frequency(pulse_frequency)
    );

    logic [3:0] target_vol;

    gb_envelopeFunction envelopeFunction (
        .clk(clk),
        .clk_vol_env(clk_vol_env),
        .start(start_posedge),
        .initial_volume(initial_volume),
        .envelope_increasing(envelope_increasing),
        .num_envelope_sweeps(num_envelope_sweeps),
        .target_vol(target_vol)
    );

    logic enable_length;

    gb_lengthFunction #(6) lengthFunction (
        .clk(clk),
        .reset(reset),
        .clk_length_ctr(clk_length_ctr),
        .start(start_posedge),
        .single(single),
        .length(length),
        .enable(enable_length)
    );

    ////////////////////
    // GENERATE PULSE //
    ////////////////////

    /* From the Pan Docs:

    The period divider for the pulse function is an 11-bit up counter. When it
    overflows, it is re-loaded with the frequency, which is either from the APU
    or the adjusted value from the Sweep Function (if the Sweep Function is
    unused these will be the same value). It also increments through our output
    waveform, which is a fixed pulse dependent on the input duty cycle.

    The period divider is incremented once every 4 T-Cycles (the system clock)
    for an effective clock rate of 2^20 (1048576) Hz.
    */

    // Holds index of current location in waveform given specified duty cycle
    logic [2:0] waveIndex = 3'b000;

    logic [10:0] periodDivider;  // 11-bit up-counter
    logic [1:0] periodDividerClock;  // Increment periodDivider every 4 T-Cycles

    always_ff @(posedge clk) begin
        if (start_posedge) begin
            waveIndex <= 3'b000;
            periodDivider <= frequency;
            periodDividerClock <= 2'b11;
        end
        else begin
            if (periodDividerClock == 2'b00) begin
                if (periodDivider == 11'd2047) begin
                    waveIndex <= waveIndex + 1;
                    periodDivider <= pulse_frequency;  // Load the sweep-calculated frequency
                end
                else
                    periodDivider <= periodDivider + 1;
            end
            periodDividerClock <= periodDividerClock - 1;
        end
    end

    /* Implement the specified duty cycle.

    The pulse will emit audio if the index of the waveform is a 1. Note that
    complimentary duty cycle ratios will generate the same sound (a 25% will
    sound the same as a 75%).

    Credit:
        https://nightshade256.github.io/2021/03/27/gb-sound-emulation.html
        https://gbdev.io/pandocs/Audio_Registers.html#ff11--nr11-channel-1-length-timer--duty-cycle

        Duty   Waveform    Ratio
        -------------------------
        00      00000001    12.5%
        01      00000011    25%
        10      00001111    50%
        11      00111111    75%
    */
    // Stores currently playing value of waveform
    logic waveValue;
    always_comb begin
        case (wave_duty)
            2'b00:
                waveValue = (waveIndex != 3'b111) ? 1'b0 : 1'b1;
            2'b01:
                waveValue = (waveIndex[2:1] != 2'b11) ? 1'b0 : 1'b1;
            2'b10:
                waveValue = (waveIndex[2]) ? 1'b1 : 1'b0;
            2'b11:
                waveValue = (waveIndex[2:1] == 2'b00) ? 1'b0 : 1'b1;
            default:
                waveValue = 1'b0;
        endcase
    end

    //////////////////
    // OUTPUT AUDIO //
    //////////////////

    // Only emit audio if the Frequency and Length Functions allow it
    assign enable = enable_length & ~overflow;

    // Output Level Logic
    assign level = (enable&waveValue) ? target_vol : 4'b0000;

endmodule  // gb_pulseChannel
