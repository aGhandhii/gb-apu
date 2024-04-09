/* Sweep Function for APU Channel 1

The goal of the sweep function is to alter the frequency of the pulse channel.

Inputs:
    clk                 - System Clock (2^22 Hz)
    clk_sweep           - Sweep Clock
    trigger             - Channel Trigger Signal
    sweep_pace          - Pace of sweep iterations
    sweep_decreasing    - Direction of Frequency Sweep
    num_sweep_shifts    - Frequency shift amount per Sweep Event
    frequency           - Original frequency value from APU Register

Outputs:
    overflow            - Frequency Shift Overflow, mute channel if true
    shadow_frequency    - True frequency value calculated with Shift Function
*/
module gb_sweepFunction (
    input logic clk,
    input logic clk_sweep,
    input logic trigger,
    input logic [2:0] sweep_pace,
    input logic sweep_decreasing,
    input logic [2:0] num_sweep_shifts,
    input logic [10:0] frequency,
    output logic overflow,
    output logic [10:0] shadow_frequency
);

    // Intermediate Signals
    logic sweep_enabled;
    logic [3:0] sweep_timer;  // We need an extra bit for default value (8)
    logic [10:0] new_frequency;
    assign new_frequency = shadow_frequency >> num_sweep_shifts;

    // Implement the sweep function
    always_ff @(posedge clk) begin
        if (trigger) begin
            // On the trigger, we set the internal control signals
            shadow_frequency <= frequency;
            sweep_timer <= (sweep_pace == 3'b000) ? 4'b1000 : {1'b0, sweep_pace};
            sweep_enabled <= ((sweep_pace != 0) && (num_sweep_shifts != 0)) ? 1'b1 : 1'b0;
            overflow <= 1'b0;
        end
        else if (clk_sweep) begin
            if (sweep_timer != 4'b0000) begin
                sweep_timer <= sweep_timer - 1;
            end
            else begin
                // Reload the sweep timer
                sweep_timer <= (sweep_pace == 3'b000) ? 4'b1000 : {1'b0, sweep_pace};
                // Apply Sweep Shift, check for overflow if we are increasing the frequency
                if (sweep_enabled) begin
                    if (sweep_decreasing)
                        shadow_frequency <= shadow_frequency - new_frequency;
                    else begin
                        // Latch overflow until a trigger if it occurs
                        if (~overflow)
                            {overflow, shadow_frequency} <= {1'b0, shadow_frequency} + {1'b0, new_frequency};
                    end
                end
            end
        end
    end

endmodule  // gb_sweepFunction
