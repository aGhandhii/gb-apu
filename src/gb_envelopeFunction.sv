/* Envelope Function for APU Channels

The Envelope Function can periodically adjust the volume of a channel. For the
Gameboy APU, this only affects channels 1,2, and 4.
In the case of a nonzero num_envelope_sweeps parameter, the output volume will
either increase or decrease to the max/min volume in a specified direction over
a period defined by num_envelope_sweeps.

Credit:
    VerilogBoy: https://github.com/zephray/VerilogBoy

Inputs:
    clk                 - System Clock
    clk_vol_env         - Envelope Volume Clock
    start               - Start Signal
    initial_volume      - Initial Envelope Volume
    envelope_increasing - Envelope Direction (0=decr, 1=incr)
    num_envelope_sweeps - Ticks of Envelope Volume Clock per Envelope Change

Outputs:
    target_vol          - Output Envelope Volume
*/
module gb_envelopeFunction (
    input logic clk,
    input logic clk_vol_env,
    input logic start,
    input logic [3:0] initial_volume,
    input logic envelope_increasing,
    input logic [2:0] num_envelope_sweeps,
    output logic [3:0] target_vol
);

    logic [2:0] enve_left; // Iterator for num_envelope_sweeps
    logic enve_enabled;
    assign enve_enabled = (num_envelope_sweeps == 3'd0) ? 0 : 1;

    // Envelope Function Implementation
    always_ff @(posedge clk) begin
        if (start) begin
            // Channel is triggered, reset to the initial volume and load the
            // envelope settings
            target_vol <= initial_volume;
            enve_left <= num_envelope_sweeps;
        end
        else if (clk_vol_env) begin
            // On a tick of the Envelope Clock, if our Envelope Sweep iterator
            // is nonzero, we adjust the output volume according to the
            // envelope direction parameter
            if (enve_left != 3'b0) begin
                enve_left <= enve_left - 1'b1;
            end
            else begin
                if (enve_enabled) begin
                    if (envelope_increasing) begin
                        if (target_vol != 4'b1111)
                            target_vol <= target_vol + 1;
                    end
                    else begin
                        if (target_vol != 4'b0000)
                            target_vol <= target_vol - 1;
                    end
                    enve_left <= num_envelope_sweeps;
                end
            end
        end
    end

endmodule  // gb_envelopeFunction
