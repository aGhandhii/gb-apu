/* Top-Level Gameboy Audio Processing Unit

This module contains Memory for the APU Control Registers and the Custom Wave
Registers, as well as handling Read/Write operations from the CPU. It connects
the corresponding APU Control Signals to their respective Channel Submodules,
and generates the Sweep, Length, and Enevelope Clocks.

Inspiration from the following projects:
    VerilogBoy: https://github.com/zephray/VerilogBoy
    IceBoy:     https://github.com/msinger/iceboy

Inputs:
    clk         - System Clock
    reset       - System Reset
    addr_i      - CPU Address In (16-bit, 0xFFXX)
    data_i      - CPU Data In (8-bit)
    wren        - CPU write enable

Outputs:
    data_o      - data from requested sound register
    left        - Left audio out
    right       - Right audio out
*/
module gb_APU (
    input logic clk,
    input logic reset,
    input logic [15:0] addr_i,
    input logic [7:0] data_i,
    input logic wren,
    output logic [7:0] data_o,
    output logic [15:0] left,
    output logic [15:0] right
);

    // Stores the sound registers
    // We declare 32 8-bit registers, we want to ensure 5-bit addressing is
    // possible. In practice, there are only 23 registers that are R/W active
    logic [7:0] regs [32];

    // Audio Register definitions (Descriptions from the Pan Docs)
    logic [7:0] reg_nr10, reg_nr11, reg_nr12, reg_nr13, reg_nr14;
    logic [7:0] reg_nr21, reg_nr22, reg_nr23, reg_nr24;
    logic [7:0] reg_nr30, reg_nr31, reg_nr32, reg_nr33, reg_nr34;
    logic [7:0] reg_nr41, reg_nr42, reg_nr43, reg_nr44;
    logic [7:0] reg_nr50, reg_nr51, reg_nr52;
    assign reg_nr10 = regs[00];  // Addr: 0xFF10 - Channel 1 Sweep
    assign reg_nr11 = regs[01];  // Addr: 0xFF11 - Channel 1 Length Timer + Duty Cycle
    assign reg_nr12 = regs[02];  // Addr: 0xFF12 - Channel 1 Volume + Envelope
    assign reg_nr13 = regs[03];  // Addr: 0xFF13 - Channel 1 Period Low (WRITE ONLY)
    assign reg_nr14 = regs[04];  // Addr: 0xFF14 - Channel 1 Period High + Control
    assign reg_nr21 = regs[06];  // Addr: 0xFF16 - Channel 2 Length Timer + Duty Cycle
    assign reg_nr22 = regs[07];  // Addr: 0xFF17 - Channel 2 Volume + Envelope
    assign reg_nr23 = regs[08];  // Addr: 0xFF18 - Channel 2 Period Low (WRITE ONLY)
    assign reg_nr24 = regs[09];  // Addr: 0xFF19 - Channel 2 Period High + Control
    assign reg_nr30 = regs[10];  // Addr: 0xFF1A - Channel 3 DAC Enable
    assign reg_nr31 = regs[11];  // Addr: 0xFF1B - Channel 3 Length Timer (WRITE ONLY)
    assign reg_nr32 = regs[12];  // Addr: 0xFF1C - Channel 3 Output Level
    assign reg_nr33 = regs[13];  // Addr: 0xFF1D - Channel 3 Period Low (WRITE ONLY)
    assign reg_nr34 = regs[14];  // Addr: 0xFF1E - Channel 3 Period High + Control
    assign reg_nr41 = regs[16];  // Addr: 0xFF20 - Channel 4 Length Timer (WRITE ONLY)
    assign reg_nr42 = regs[17];  // Addr: 0xFF21 - Channel 4 Volume + Envelope
    assign reg_nr43 = regs[18];  // Addr: 0xFF22 - Channel 4 Frequency + Randomness
    assign reg_nr44 = regs[19];  // Addr: 0xFF23 - Channel 4 Control
    assign reg_nr50 = regs[20];  // Addr: 0xFF24 - Master Volume + VIN panning
    assign reg_nr51 = regs[21];  // Addr: 0xFF25 - Sound Panning
    assign reg_nr52 = regs[22];  // Addr: 0xFF26 - Audio Master Control

    /////////////////////////
    // REGISTER PARAMETERS //
    /////////////////////////

    // Channel 1 (Square Wave w/ Envelope and Sweep)
    logic [2:0]  ch1_sweep_time;
    logic        ch1_sweep_decreasing;
    logic [2:0]  ch1_num_sweep_shifts;
    logic [1:0]  ch1_wave_duty;
    logic [5:0]  ch1_length;  // WRITE ONLY
    logic [3:0]  ch1_initial_volume;
    logic        ch1_envelope_increasing;
    logic [2:0]  ch1_num_envelope_sweeps;
    logic [10:0] ch1_frequency;
    logic        ch1_start;  // Corresponds to the 'trigger' value
    logic        ch1_single;
    assign ch1_sweep_time = reg_nr10[6:4];
    assign ch1_sweep_decreasing = reg_nr10[3];
    assign ch1_num_sweep_shifts = reg_nr10[2:0];
    assign ch1_wave_duty = reg_nr11[7:6];
    assign ch1_length = reg_nr11[5:0];
    assign ch1_initial_volume = reg_nr12[7:4];
    assign ch1_envelope_increasing = reg_nr12[3];
    assign ch1_num_envelope_sweeps = reg_nr12[2:0];
    assign ch1_frequency = {reg_nr14[2:0], reg_nr13[7:0]};
    assign ch1_single = reg_nr14[6];

    // Channel 2 (Square Wave w/ Envelope)
    logic [1:0]  ch2_wave_duty;
    logic [5:0]  ch2_length;
    logic [3:0]  ch2_initial_volume;
    logic        ch2_envelope_increasing;
    logic [2:0]  ch2_num_envelope_sweeps;
    logic [10:0] ch2_frequency;
    logic        ch2_start;  // Corresponds to the 'trigger' value
    logic        ch2_single;
    assign ch2_wave_duty = reg_nr21[7:6];
    assign ch2_length = reg_nr21[5:0];
    assign ch2_initial_volume = reg_nr22[7:4];
    assign ch2_envelope_increasing = reg_nr22[3];
    assign ch2_num_envelope_sweeps = reg_nr22[2:0];
    assign ch2_frequency = {reg_nr24[2:0], reg_nr23[7:0]};
    assign ch2_single = reg_nr24[6];

    // Channel 3 (Custom Wave)
    logic        ch3_on;
    logic [7:0]  ch3_length;  // Initial Length Timer - WRITE ONLY
    logic [1:0]  ch3_volume;  // 00 - Mute, 01 - 100%, 10 - 50%, 11 - 25%
    logic [10:0] ch3_frequency;
    logic        ch3_start;  // Corresponds to the 'trigger' value
    logic        ch3_single;
    assign ch3_on = reg_nr30[7];
    assign ch3_length = reg_nr31[7:0];
    assign ch3_volume = reg_nr32[6:5];
    assign ch3_frequency = {reg_nr34[2:0], reg_nr33[7:0]};
    assign ch3_single = reg_nr34[6];

    // Channel 4 (Random Noise w/ Envelope)
    logic [5:0] ch4_length;  // Inital Length Timer - WRITE ONLY
    logic [3:0] ch4_initial_volume;
    logic       ch4_envelope_increasing;
    logic [2:0] ch4_num_envelope_sweeps;
    logic [3:0] ch4_shift_clock_freq;
    logic       ch4_counter_width; // 0 = 15 bits, 1 = 7 bits
    logic [2:0] ch4_freq_dividing_ratio;
    logic       ch4_start;  // Corresponds to the 'trigger' value
    logic       ch4_single;  // Length Enable
    assign ch4_length = reg_nr41[5:0];
    assign ch4_initial_volume = reg_nr42[7:4];
    assign ch4_envelope_increasing = reg_nr42[3];
    assign ch4_num_envelope_sweeps = reg_nr42[2:0];
    assign ch4_shift_clock_freq = reg_nr43[7:4];
    assign ch4_counter_width = reg_nr43[3];
    assign ch4_freq_dividing_ratio = reg_nr43[2:0];
    assign ch4_single = reg_nr44[6];  // Length Enable

    // Global Audio Control
    logic [2:0] left_output_level, right_output_level;
    logic left_ch4_enable, left_ch3_enable, left_ch2_enable, left_ch1_enable;
    logic right_ch4_enable, right_ch3_enable, right_ch2_enable, right_ch1_enable;
    logic sound_enable;  // Master Sound Control
    assign left_output_level = reg_nr50[6:4];
    assign right_output_level = reg_nr50[2:0];
    assign left_ch4_enable = reg_nr51[7];
    assign left_ch3_enable = reg_nr51[6];
    assign left_ch2_enable = reg_nr51[5];
    assign left_ch1_enable = reg_nr51[4];
    assign right_ch4_enable = reg_nr51[3];
    assign right_ch3_enable = reg_nr51[2];
    assign right_ch2_enable = reg_nr51[1];
    assign right_ch1_enable = reg_nr51[0];
    assign sound_enable = reg_nr52[7];

    // The 'on' flags are read-only
    logic  ch4_on_flag, ch3_on_flag, ch2_on_flag, ch1_on_flag;

    ////////////////////////////////
    // CUSTOM WAVE MEMORY CONTROL //
    ////////////////////////////////

    // System issues occur when accessing Wave Memory while Channel 3 is active
    // so we give priority to Channel 3 for Wave Memory Access
    // In practice, we need to disable channel 3 before writing to Wave Memory
    logic [7:0] wave [16];
    logic [3:0] wave_addr_ext;  // in range 0x0 - 0xF, to access 0xFF30 - 0xFF3F
    logic [3:0] wave_addr_int;  // Used by Custom Wave Channel to read wave data
    logic [3:0] wave_addr;
    logic [7:0] wave_data;

    always_comb begin
        wave_addr_ext = addr_i[3:0];
        wave_addr = (ch3_on) ? (wave_addr_int) : (wave_addr_ext);
        wave_data = wave[wave_addr];
    end

    /////////////////////////////
    // CPU READ/WRITE HANDLING //
    /////////////////////////////

    // Handy Internal Control Signals
    logic addr_in_regs;
    logic addr_in_wave;
    assign addr_in_regs = (addr_i >= 16'hFF10 && addr_i <= 16'hFF2F);
    assign addr_in_wave = (addr_i >= 16'hFF30 && addr_i <= 16'hFF3F);

    // APU Registers are in 0xFF10-0xFF26, and we want to use the last 5 bits
    // of the address to access our APU Registers. If bit 5 of the full address
    // is high, we are reading from 0xFF1X, and if the top-bit is low, we read
    // from 0xFF2X. By flipping the top-bit, our 5-bit input now reads in the
    // same order of increasing addresses, and can linearily access our APU
    // registers from 0-32
    logic [4:0] reg_addr;
    assign reg_addr = {~addr_i[4], addr_i[3:0]};

    // CPU Reads
    always_comb begin
        if (addr_in_regs) begin
            if (addr_i == 16'hFF26)
                data_o = {sound_enable, 3'b000, ch4_on_flag, ch3_on_flag, ch2_on_flag, ch1_on_flag};
            else
                data_o = regs[reg_addr];
        end
        else if (addr_in_wave) begin
            data_o = wave[wave_addr];
        end else begin
            data_o = 8'hFF;  // Default Return Value
        end
    end

    // CPU Writes
    integer i;
    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i+1) begin: resetAudioRegisters
                regs[i] <= 8'h00;
            end
        end
        else begin
            if (wren) begin
                // Handle Write Requests to the Audio Control Registers
                if (addr_in_regs) begin
                    // Check for change of Master Audio Bit
                    if ((addr_i == 16'hFF26) && (data_i[7] == 1'b0)) begin
                        for (i = 0; i < 32; i = i+1) begin: masterResetAudio
                            regs[i] <= 8'h00;
                        end
                    end
                    else if (sound_enable || ((addr_i == 16'hFF26)&&(data_i[7] == 1'b1))) begin
                        regs[reg_addr] <= data_i;
                    end
                end
                else if (addr_in_wave) begin
                    // Write to the custom wave address
                    wave[wave_addr] <= data_i;
                end
            end
            // Sets the 'Trigger' Value for each channel
            // We do this at the clock so it is only set for 1 cycle
            if ((wren)&&(addr_i == 16'hFF14))
                ch1_start <= data_i[7];
            else
                ch1_start <= 0;
            if ((wren)&&(addr_i == 16'hFF19))
                ch2_start <= data_i[7];
            else
                ch2_start <= 0;
            if ((wren)&&(addr_i == 16'hFF1E))
                ch3_start <= data_i[7];
            else
                ch3_start <= 0;
            if ((wren)&&(addr_i == 16'hFF23))
                ch4_start <= data_i[7];
            else
                ch4_start <= 0;
        end
    end

    ////////////////////////////////////
    // FRAME SEQUENCER CLOCK DIVISION //
    ////////////////////////////////////

    logic clk_length_ctr; // 256Hz Length Control Clock
    logic clk_vol_env;    // 64Hz Volume Enevelope Clock
    logic clk_sweep;      // 128Hz Sweep Clock

    gb_frameSequencer APUclockDivider (
        .clk(clk),
        .reset(reset),
        .length_clk(clk_length_ctr),
        .envelope_clk(clk_vol_env),
        .sweep_clk(clk_sweep)
    );

    ///////////////////////
    // CHANNEL INSTANCES //
    ///////////////////////

    // Store Channel Outputs
    logic [3:0] ch1;
    logic [3:0] ch2;
    logic [3:0] ch3;
    logic [3:0] ch4;

    // Channel 1 Submodule. This channel is a pulse function with Sweep, Level,
    // and Envelope Functions
    gb_pulseChannel channel_1(
        .reset(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .clk_sweep(clk_sweep),
        .sweep_time(ch1_sweep_time),
        .sweep_decreasing(ch1_sweep_decreasing),
        .num_sweep_shifts(ch1_num_sweep_shifts),
        .wave_duty(ch1_wave_duty),
        .length(ch1_length),
        .initial_volume(ch1_initial_volume),
        .envelope_increasing(ch1_envelope_increasing),
        .num_envelope_sweeps(ch1_num_envelope_sweeps),
        .start(ch1_start),
        .single(ch1_single),
        .frequency(ch1_frequency),
        .level(ch1),
        .enable(ch1_on_flag)
    );

    // Channel 2 Submodule. This Channel is a pulse function with Level and
    // Envelope Functions. It does NOT implement the Sweep Function, so we pass
    // all Sweep parameters as 0.
    gb_pulseChannel channel_2(
        .reset(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .clk_sweep(clk_sweep),
        .sweep_time(3'b000),
        .sweep_decreasing(1'b0),
        .num_sweep_shifts(3'b000),
        .wave_duty(ch2_wave_duty),
        .length(ch2_length),
        .initial_volume(ch2_initial_volume),
        .envelope_increasing(ch2_envelope_increasing),
        .num_envelope_sweeps(ch2_num_envelope_sweeps),
        .start(ch2_start),
        .single(ch2_single),
        .frequency(ch2_frequency),
        .level(ch2),
        .enable(ch2_on_flag)
    );

    // Channel 3 Submodule. This channel reads from a 16-byte section of memory
    // in 4-bit nibbles as a customized waveform. It also has a Level and
    // Envelope function.
    gb_customWaveChannel channel_3(
        .reset(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .length(ch3_length),
        .volume(ch3_volume),
        .on(ch3_on),
        .single(ch3_single),
        .start(ch3_start),
        .frequency(ch3_frequency),
        .wave_addr(wave_addr_int),
        .wave_data(wave_data),
        .level(ch3),
        .enable(ch3_on_flag)
    );

    // Channel 4 Submodule. This channel generates noise with an LFSR and has
    // Level and Enevelope Functions.
    gb_noiseChannel channel_4(
        .reset(~sound_enable),
        .clk(clk),
        .clk_length_ctr(clk_length_ctr),
        .clk_vol_env(clk_vol_env),
        .length(ch4_length),
        .initial_volume(ch4_initial_volume),
        .envelope_increasing(ch4_envelope_increasing),
        .num_envelope_sweeps(ch4_num_envelope_sweeps),
        .shift_clock_freq(ch4_shift_clock_freq),
        .counter_width(ch4_counter_width),
        .freq_dividing_ratio(ch4_freq_dividing_ratio),
        .start(ch4_start),
        .single(ch4_single),
        .level(ch4),
        .enable(ch4_on_flag)
    );

    ////////////////
    // MIXER UNIT //
    ////////////////

    /* This section prototypes the DAC, Mixer, and Volume Modules from the
    Pan Docs diagram: https://gbdev.io/pandocs/Audio_details.html

    Essentially, there are 4 DAC modules, each taking the 4-bit volume output
    from each channel, as well as the channel enable signals.

    The 4 DAC modules send their analog outputs to the Mixer module, which
    uses the control signals in NR51 to selectively mix DAC inputs on the
    specified channels and ports (left or right). This allows for outputs up
    to 4x the DAC inputs, so we add an extra 2 bits for a 6-bit output.

    Lastly, the left and right mixer signals are sent to the Volume module,
    which are multiplied by the 3-bit volume control signals from NR50. This
    can be at most a 7x boost, so we add 3 additional bits to this output for
    two 9-bit outputs corresponding to left and right.

    In physical hardware, the outputs from the Volume module are sent through
    High-Pass filters.
    */
    logic [5:0] DAC_sum_left;
    logic [5:0] DAC_sum_right;
    always_comb begin
        DAC_sum_left = 6'd0;
        DAC_sum_right = 6'd0;
        if (left_ch1_enable) DAC_sum_left = DAC_sum_left + {2'b00, ch1};
        if (left_ch2_enable) DAC_sum_left = DAC_sum_left + {2'b00, ch2};
        if (left_ch3_enable) DAC_sum_left = DAC_sum_left + {2'b00, ch3};
        if (left_ch4_enable) DAC_sum_left = DAC_sum_left + {2'b00, ch4};
        if (right_ch1_enable) DAC_sum_right = DAC_sum_right + {2'b00, ch1};
        if (right_ch2_enable) DAC_sum_right = DAC_sum_right + {2'b00, ch2};
        if (right_ch3_enable) DAC_sum_right = DAC_sum_right + {2'b00, ch3};
        if (right_ch4_enable) DAC_sum_right = DAC_sum_right + {2'b00, ch4};
    end

    // Mixer Unit
    logic [8:0] mixer_sum_left;
    logic [8:0] mixer_sum_right;
    assign mixer_sum_left = DAC_sum_left * left_output_level;
    assign mixer_sum_right = DAC_sum_right * right_output_level;

    // Volume Unit
    // Outputs are SIGNED 16-bit values, change this to hardware specification
    assign left  = (sound_enable) ? {1'b0, mixer_sum_left[8:0], 6'b0} : 16'b0;
    assign right = (sound_enable) ? {1'b0, mixer_sum_right[8:0], 6'b0} : 16'b0;

endmodule  // gb_APU
