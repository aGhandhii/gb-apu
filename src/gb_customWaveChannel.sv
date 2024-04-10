/* Gameboy APU Custom Wave Channel

Credit:
    VerilogBoy: https://github.com/zephray/VerilogBoy

Controls Channel 3, reads user-defined Wave from memory in [0xFF30-0xFF3F],
where samples are in 4-bit nibbles, so 32 samples in total. Samples are read
in bytes, where first portion is the upper nibble and the second portion is
the lower nibble.

Inputs:
    reset           - System Reset
    clk             - System Clock
    clk_length_ctr  - Length Function Clock
    length          - Length Function Specifier
    volume          - 00=Mute, 01=100%, 10=50%, 11=25%
    on              - Unclocked Trigger, prevents CPU overwriting Wave Memory when Ch 3 is active
    single          - Length Function Enable
    start           - Trigger
    frequency       - Channel Period Value, f = 65536 / (2048 - frequency)
    wave_data       - Data from Wave Memory

Outputs:
    wave_addr       - Address in Wave Memory to Read From
    level           - Output Audio Level
    enable          - Output Length Function Enable
*/
module gb_customWaveChannel (
    input logic reset,
    input logic clk,
    input logic clk_length_ctr,
    input logic [7:0] length,
    input logic [1:0] volume,
    input logic on,
    input logic single,
    input logic start,
    input logic [10:0] frequency,
    input logic [7:0] wave_data,
    output logic [3:0] wave_addr,
    output logic [3:0] level,
    output logic enable
);

    // Posedge detection for the trigger
    logic start_posedge;
    edgeDetector start_edgeDetection (
        .clk(clk),
        .i(start),
        .o(start_posedge)
    );

    // Specifies the current nibble in Custom Wave Memory to load, the top
    // four bits represent the address (0xFFXX), where address is in (0x30-3F),
    // and the bottom bit represents the nibble (0=top 4, 1=bottom 4)
    logic [4:0] current_pointer;

    // This stores the desired nibble from wave memory
    logic [3:0] current_sample;

    // Set the wave address and sample as specified above
    assign wave_addr[3:0] = current_pointer[4:1];
    assign current_sample[3:0] = (current_pointer[0]) ? (wave_data[3:0]) : (wave_data[7:4]);

    // Up-Counter for period divider. This channel's divider is clocked every
    // 2 T-Cycles, so we just add an extra bit to the end.
    logic [11:0] divider;

    // Upon a trigger, we move back to the start of the Wave Memory
    // On a trigger or a divider overload, we set the divider to 2*frequency
    // On divider overloads, we increment the wave pointer to the next nibble
    // Otherwise, we increment the divider on T-Cycles
    always_ff @(posedge clk) begin
        if (start_posedge) begin
            divider <= {frequency, 1'b0};  // 2*frequency
            current_pointer <= 5'd0;
        end
        else begin
            if (divider == 12'd4095) begin
                if (on)
                    current_pointer <= current_pointer + 1'b1;
                divider <= {frequency, 1'b0};
            end
            else begin
                divider <= divider + 1'b1;
            end
        end
    end

    // Length Function
    gb_lengthFunction #(8) lengthFunction (
        .clk(clk),
        .reset(reset),
        .clk_length_ctr(clk_length_ctr),
        .start(start),
        .single(single),
        .length(length),
        .enable(enable)
    );

    // Output Level Logic
    always_comb begin
        if (on) begin
            case (volume)
                2'b00: level = 4'b0000;
                2'b01: level = current_sample[3:0];
                2'b10: level = {1'b0, current_sample[3:1]};  // >> 1
                2'b11: level = {2'b00, current_sample[3:2]}; // >> 2
                default: level = 4'b0000;
            endcase
        end
        else begin
            level = 4'b0000;  // Mute
        end
    end

endmodule  // gb_customWaveChannel
