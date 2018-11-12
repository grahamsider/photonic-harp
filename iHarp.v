/**
 *	iHarp_v11.2_sensor
 *	
 *	by Graham Sider
 *	& Michael Hong
 *	
 *	UofT 2T0
 *	ECE241 2017
 */



`timescale 1ns / 1ns // `timescale time_unit/time_precision

module iHarp(
	input 	CLOCK_50,		// 50MHz
	input 	[9:0]	SW,		// SW[9] = Active high reset -;- SW[8:7] = Up/down a semitone -;- SW[1:0] = Note duration/sustain
	input 	[3:0]	KEY,	// Octave modulators
	input	[9:2] GPIO_0,	// Notes C -> High C (8 total)
	
	output	FPGA_I2C_SCLK,	// I2C
	inout	FPGA_I2C_SDAT,	// I2C
	
	inout	AUD_BCLK,		// Audio CODEC Bit-Stream Clock
	inout	AUD_ADCLRCK,	// Audio CODEC ADC Left Right Clock
	inout	AUD_DACLRCK,	// Audio CODEC DAC Left Right Clock
	output	AUD_XCK,		// Audio CODEC Chip Clock
	output	AUD_DACDAT		// Audio CODEC DAC Data
);
	
	
	/**
	 *	INSTANTIATIONS
	 */
	
	
	// avconf instantiation
	avconf u0(
		// Host Side
		.CLOCK_50(CLOCK_50),
		.reset(SW[9]),
		
		// I2C Side
		.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
		.FPGA_I2C_SDAT(FPGA_I2C_SDAT)
	);
	
	// Audio_Controller instantiation
	Audio_Controller u1(
		// Inputs
		.CLOCK_50(CLOCK_50),
		.reset(SW[9]),
		
		.clear_audio_in_memory(),
		.read_audio_in(),
		
		.clear_audio_out_memory(clear_audio_out_memory),
		.left_channel_audio_out(channel_audio_out),
		.right_channel_audio_out(channel_audio_out),
		.write_audio_out(write_audio_out),
		
		.AUD_ADCDAT(),
		
		// Bidirectionals
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),
		
		// Outputs
		.left_channel_audio_in(),
		.right_channel_audio_in(),
		.audio_in_available(),
		.audio_out_allowed(audio_out_allowed),
		.AUD_XCK(AUD_XCK),
		.AUD_DACDAT(AUD_DACDAT)
	);
	
	// Octave and semitone modulation (os_mod) instantiation
	os_mod u2(
		// Inputs
		.reset(SW[9]),
		.octave(KEY),
		.semi(SW[8]),
		.s_up_down(SW[7]),
	
		// Outputs
		.hdc_C(hdc_C),
		.hdc_D(hdc_D),
		.hdc_E(hdc_E),
		.hdc_F(hdc_F),
		.hdc_G(hdc_G),
		.hdc_A(hdc_A),
		.hdc_B(hdc_B),
		.hdc_C_h(hdc_C_h) // High C
	);
	
	// Countdowns for stringlike
	slike_rd u3(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_C),
		.fin(fin_C),
		.half(s_half_C)
	);
	slike_rd u4(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_D),
		.fin(fin_D),
		.half(s_half_D)
	);
	slike_rd u5(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_E),
		.fin(fin_E),
		.half(s_half_E)
	);
	slike_rd u6(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_F),
		.fin(fin_F),
		.half(s_half_F)
	);
	slike_rd u7(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_G),
		.fin(fin_G),
		.half(s_half_G)
	);
	slike_rd u8(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_A),
		.fin(fin_A),
		.half(s_half_A)
	);
	slike_rd u9(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_B),
		.fin(fin_B),
		.half(s_half_B)
	);
	slike_rd u10(
		.reset(SW[9]),
		.CLOCK_50(CLOCK_50),
		.max_count(26'd49999999),
		.countdown(countdown_C_h),
		.fin(fin_C_h),
		.half(s_half_C_h)
	);
	
		
	/**
	 *	AUDIO LOGIC
	 */
	
	
	/**
	 *	SQUARE WAVE MAKER
	 */
	
	
	// Positive and negative amplitude parameters for square wave
	parameter pos_amp = 32'h10000000;
	parameter neg_amp = 32'hF0000000;
	
	// Determines channel_audio_out via dac_out dependant on can_out and s_half
	wire signed [31:0] channel_audio_out1 = can_out_C ? 32'd0 : s_half_C ? (dac_out_C ? s_pos_amp_C : -s_pos_amp_C) : (dac_out_C ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out2 = can_out_D ? 32'd0 : s_half_D ? (dac_out_D ? s_pos_amp_D : -s_pos_amp_D) : (dac_out_D ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out3 = can_out_E ? 32'd0 : s_half_E ? (dac_out_E ? s_pos_amp_E : -s_pos_amp_E) : (dac_out_E ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out4 = can_out_F ? 32'd0 : s_half_F ? (dac_out_F ? s_pos_amp_F : -s_pos_amp_F) : (dac_out_F ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out5 = can_out_G ? 32'd0 : s_half_G ? (dac_out_G ? s_pos_amp_G : -s_pos_amp_G) : (dac_out_G ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out6 = can_out_A ? 32'd0 : s_half_A ? (dac_out_A ? s_pos_amp_A : -s_pos_amp_A) : (dac_out_A ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out7 = can_out_B ? 32'd0 : s_half_B ? (dac_out_B ? s_pos_amp_B : -s_pos_amp_B) : (dac_out_B ? pos_amp : neg_amp);
	wire signed [31:0] channel_audio_out8 = can_out_C_h ? 32'd0 : s_half_C_h ? (dac_out_C_h ? s_pos_amp_C_h : -s_pos_amp_C_h) : (dac_out_C_h ? pos_amp : neg_amp); // High C
	
	// Note adder
	wire signed [31:0] channel_audio_out = channel_audio_out1 + channel_audio_out2 + channel_audio_out3 + channel_audio_out4 + channel_audio_out5 + channel_audio_out6 + channel_audio_out7 + channel_audio_out8;
	
	// 20-bit counter for each note
	reg [19:0] counter_C;
	reg [19:0] counter_D;
	reg [19:0] counter_E;
	reg [19:0] counter_F;
	reg [19:0] counter_G;
	reg [19:0] counter_A;
	reg [19:0] counter_B;
	reg [19:0] counter_C_h; // High C
	
	// To clear audio_out buffer when no SW is flipped
	reg clear_audio_out_memory;
	
	// To signal when to write to audio_out buffer
	reg write_audio_out;
	
	// Determines pos_amp or neg_amp for channel_audio_out
	reg dac_out_C;
	reg dac_out_D;
	reg dac_out_E;
	reg dac_out_F;
	reg dac_out_G;
	reg dac_out_A;
	reg dac_out_B;
	reg dac_out_C_h; // High C
	
	// Determines whether a note is on or off (1 = off, 0 = on)
	reg can_out_C;
	reg can_out_D;
	reg can_out_E;
	reg can_out_F;
	reg can_out_G;
	reg can_out_A;
	reg can_out_B;
	reg can_out_C_h; // High C
	
	// Half duty cycle of each note
	wire [19:0] hdc_C;
	wire [19:0] hdc_D;
	wire [19:0] hdc_E;
	wire [19:0] hdc_F;
	wire [19:0] hdc_G;
	wire [19:0] hdc_A;
	wire [19:0] hdc_B;
	wire [19:0] hdc_C_h; // High C
	
	
	/**
	 *	NOTE DURATION LOGIC
	 */
	
	
	// audio_out_allowed wire for fade out
	wire audio_out_allowed;
	
	// Positive amplitude reg's for stringlike square wave (fade-out)
	reg signed [31:0] s_pos_amp_C;
	reg signed [31:0] s_pos_amp_D;
	reg signed [31:0] s_pos_amp_E;
	reg signed [31:0] s_pos_amp_F;
	reg signed [31:0] s_pos_amp_G;
	reg signed [31:0] s_pos_amp_A;
	reg signed [31:0] s_pos_amp_B;
	reg signed [31:0] s_pos_amp_C_h;
	
	// Determines whether to start countdown in slike_rd (stringlike rate-divider) module
	reg countdown_C;
	reg countdown_D;
	reg countdown_E;
	reg countdown_F;
	reg countdown_G;
	reg countdown_A;
	reg countdown_B;
	reg countdown_C_h;
	
	// Determines when countdown in slike_rd has finished (1 second)
	wire fin_C;
	wire fin_D;
	wire fin_E;
	wire fin_F;
	wire fin_G;
	wire fin_A;
	wire fin_B;
	wire fin_C_h;
	
	// Determines when countdown in slike_rd has reached half-way (0.5 seconds)
	wire s_half_C;
	wire s_half_D;
	wire s_half_E;
	wire s_half_F;
	wire s_half_G;
	wire s_half_A;
	wire s_half_B;
	wire s_half_C_h;
	
	// Determines whether or not to stop the note
	reg stop_C;
	reg stop_D;
	reg stop_E;
	reg stop_F;
	reg stop_G;
	reg stop_A;
	reg stop_B;
	reg stop_C_h;
	
	
	/**
	 *	ALWAYS BLOCK
	 */
	
	
	// Determines dac_out via ac_counter's (CLOCK_50 dividers)
	always@(posedge CLOCK_50) // 50MHz
	begin
		clear_audio_out_memory <= 1'b0;
		/**
		 *	NO LASERS OBSTRUCTED
		 */
		if (GPIO_0[9:2] == 5'd1 && SW[1] != 1'b1 && SW[0] != 1'b1)
			begin
				write_audio_out <= 1'b0;
				clear_audio_out_memory <= 1'b1;
			end
		else
			begin
				/**
				 *	C
				 */
				if (GPIO_0[2] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_C <= pos_amp;
						countdown_C <= 1'b0;
						stop_C <= 1'b0;
						can_out_C <= 1'b0;	
						counter_C <= counter_C + 1'b1;
						if (counter_C >= ((hdc_C * 2) - 1'b1))
							counter_C <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_C <= (counter_C < hdc_C) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_C == 1'b0)
							case(SW[1:0])
								2'b00: stop_C <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_C <= 1'b0;	
									counter_C <= counter_C + 1'b1;
									if (counter_C >= ((hdc_C * 2) - 1'b1))
										counter_C <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_C <= (counter_C < hdc_C) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_C <= 1'b1;
									if (fin_C == 1'b1)
											stop_C <= 1'b1;
									else if (s_half_C == 1'b1)
										begin
											can_out_C <= 1'b0;
											counter_C <= counter_C + 1'b1;
											if (counter_C >= ((hdc_C * 2) - 1'b1))
												counter_C <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_C <= s_pos_amp_C - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_C <= (counter_C < hdc_C) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_C <= 1'b0;
											counter_C <= counter_C + 1'b1;
											if (counter_C >= ((hdc_C * 2) - 1'b1))
												counter_C <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_C <= (counter_C < hdc_C) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_C <= 1'b0;	
									counter_C <= counter_C + 1'b1;
									if (counter_C >= ((hdc_C * 2) - 1'b1))
										counter_C <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_C <= (counter_C < hdc_C) ? 1'b1 : 1'b0;
								end
							endcase
						else
							// STOP NOTE
							begin
								s_pos_amp_C <= pos_amp;
								countdown_C <= 1'b0;
								stop_C <= 1'b1;
								can_out_C <= 1'b1;	
								counter_C <= 1'd0;
								dac_out_C <= 1'b0;
							end
					end
				/**
				 *	D
				 */
				if (GPIO_0[3] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_D <= pos_amp;
						countdown_D <= 1'b0;
						stop_D <= 1'b0;
						can_out_D <= 1'b0;	
						counter_D <= counter_D + 1'b1;
						if (counter_D >= ((hdc_D * 2) - 1'b1))
							counter_D <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_D <= (counter_D < hdc_D) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_D == 1'b0)
							case(SW[1:0])
								2'b00: stop_D <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_D <= 1'b0;	
									counter_D <= counter_D + 1'b1;
									if (counter_D >= ((hdc_D * 2) - 1'b1))
										counter_D <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_D <= (counter_D < hdc_D) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_D <= 1'b1;
									if (fin_D == 1'b1)
											stop_D <= 1'b1;
									else if (s_half_D == 1'b1)
										begin
											can_out_D <= 1'b0;	
											counter_D <= counter_D + 1'b1;
											if (counter_D >= ((hdc_D * 2) - 1'b1))
												counter_D <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_D <= s_pos_amp_D - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_D <= (counter_D < hdc_D) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_D <= 1'b0;	
											counter_D <= counter_D + 1'b1;
											if (counter_D >= ((hdc_D * 2) - 1'b1))
												counter_D <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_D <= (counter_D < hdc_D) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_D <= 1'b0;	
									counter_D <= counter_D + 1'b1;
									if (counter_D >= ((hdc_D * 2) - 1'b1))
										counter_D <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_D <= (counter_D < hdc_D) ? 1'b1 : 1'b0;
								end
							endcase
						else
							begin
								s_pos_amp_D <= pos_amp;
								countdown_D <= 1'b0;
								stop_D <= 1'b1;
								can_out_D <= 1'b1;	
								counter_D <= 1'd0;
								dac_out_D <= 1'b0;
							end
					end
				/**
				 *	E
				 */
				if (GPIO_0[4] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_E <= pos_amp;
						countdown_E <= 1'b0;
						stop_E <= 1'b0;
						can_out_E <= 1'b0;	
						counter_E <= counter_E + 1'b1;
						if (counter_E >= ((hdc_E * 2) - 1'b1))
							counter_E <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_E <= (counter_E < hdc_E) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_E == 1'b0)
							case(SW[1:0])
								2'b00: stop_E <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_E <= 1'b0;	
									counter_E <= counter_E + 1'b1;
									if (counter_E >= ((hdc_E * 2) - 1'b1))
										counter_E <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_E <= (counter_E < hdc_E) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_E <= 1'b1;
									if (fin_E == 1'b1)
											stop_E <= 1'b1;
									else if (s_half_E == 1'b1)
										begin
											can_out_E <= 1'b0;	
											counter_E <= counter_E + 1'b1;
											if (counter_E >= ((hdc_E * 2) - 1'b1))
												counter_E <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_E <= s_pos_amp_E - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_E <= (counter_E < hdc_E) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_E <= 1'b0;	
											counter_E <= counter_E + 1'b1;
											if (counter_E >= ((hdc_E * 2) - 1'b1))
												counter_E <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_E <= (counter_E < hdc_E) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_E <= 1'b0;	
									counter_E <= counter_E + 1'b1;
									if (counter_E >= ((hdc_E * 2) - 1'b1))
										counter_E <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_E <= (counter_E < hdc_E) ? 1'b1 : 1'b0;
								end
							endcase
						else
							begin
								s_pos_amp_E <= pos_amp;
								countdown_E <= 1'b0;
								stop_E <=1'b1;
								can_out_E <= 1'b1;	
								counter_E <= 1'd0;
								dac_out_E <= 1'b0;
							end
					end
				/**
				 *	F
				 */
				if (GPIO_0[5] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_F <= pos_amp;
						countdown_F <= 1'b0;
						stop_F <= 1'b0;
						can_out_F <= 1'b0;	
						counter_F <= counter_F + 1'b1;
						if (counter_F >= ((hdc_F * 2) - 1'b1))
							counter_F <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_F <= (counter_F < hdc_F) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_F == 1'b0)
							case(SW[1:0])
								2'b00: stop_F <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_F <= 1'b0;	
									counter_F <= counter_F + 1'b1;
									if (counter_F >= ((hdc_F * 2) - 1'b1))
										counter_F <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_F <= (counter_F < hdc_F) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_F <= 1'b1;
									if (fin_F == 1'b1)
											stop_F <= 1'b1;
									else if (s_half_F == 1'b1)
										begin
											can_out_F <= 1'b0;	
											counter_F <= counter_F + 1'b1;
											if (counter_F >= ((hdc_F * 2) - 1'b1))
												counter_F <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1) 
												s_pos_amp_F <= s_pos_amp_F - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_F <= (counter_F < hdc_F) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_F <= 1'b0;	
											counter_F <= counter_F + 1'b1;
											if (counter_F >= ((hdc_F * 2) - 1'b1))
												counter_F <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_F <= (counter_F < hdc_F) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_F <= 1'b0;	
									counter_F <= counter_F + 1'b1;
									if (counter_F >= ((hdc_F * 2) - 1'b1))
										counter_F <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_F <= (counter_F < hdc_F) ? 1'b1 : 1'b0;
								end
							endcase
						else
							begin
								s_pos_amp_F <= pos_amp;
								countdown_F <= 1'b0;
								stop_F <= 1'b1;
								can_out_F <= 1'b1;	
								counter_F <= 1'd0;
								dac_out_F <= 1'b0;
							end
					end
				/**
				 *	G
				 */
				if (GPIO_0[6] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_G <= pos_amp;
						countdown_G <= 1'b0;
						stop_G <= 1'b0;
						can_out_G <= 1'b0;	
						counter_G <= counter_G + 1'b1;
						if (counter_G >= ((hdc_G * 2) - 1'b1))
							counter_G <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_G <= (counter_G < hdc_G) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_G == 1'b0)
							case(SW[1:0])
								2'b00: stop_G <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_G <= 1'b0;	
									counter_G <= counter_G + 1'b1;
									if (counter_G >= ((hdc_G * 2) - 1'b1))
										counter_G <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_G <= (counter_G < hdc_G) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_G <= 1'b1;
									if (fin_G == 1'b1)
											stop_G <= 1'b1;
									else if (s_half_G == 1'b1)
										begin
											can_out_G <= 1'b0;	
											counter_G <= counter_G + 1'b1;
											if (counter_G >= ((hdc_G * 2) - 1'b1))
												counter_G <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_G <= s_pos_amp_G - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_G <= (counter_G < hdc_G) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_G <= 1'b0;	
											counter_G <= counter_G + 1'b1;
											if (counter_G >= ((hdc_G * 2) - 1'b1))
												counter_G <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_G <= (counter_G < hdc_G) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_G <= 1'b0;	
									counter_G <= counter_G + 1'b1;
									if (counter_G >= ((hdc_G * 2) - 1'b1))
										counter_G <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_G <= (counter_G < hdc_G) ? 1'b1 : 1'b0;
								end
							endcase
						else
							begin
								s_pos_amp_G <= pos_amp;
								countdown_G <= 1'b0;
								stop_G <= 1'b1;
								can_out_G <= 1'b1;	
								counter_G <= 1'd0;
								dac_out_G <= 1'b0;
							end
					end
				/**
				 *	A
				 */
				if (GPIO_0[7] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_A <= pos_amp;
						countdown_A <= 1'b0;
						stop_A <= 1'b0;
						can_out_A <= 1'b0;	
						counter_A <= counter_A + 1'b1;
						if (counter_A >= ((hdc_A * 2) - 1'b1))
							counter_A <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_A <= (counter_A < hdc_A) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_A == 1'b0)
							case(SW[1:0])
								2'b00: stop_A <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_A <= 1'b0;	
									counter_A <= counter_A + 1'b1;
									if (counter_A >= ((hdc_A * 2) - 1'b1))
										counter_A <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_A <= (counter_A < hdc_A) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_A <= 1'b1;
									if (fin_A == 1'b1)
											stop_A <= 1'b1;
									else if (s_half_A == 1'b1)
										begin
											can_out_A <= 1'b0;	
											counter_A <= counter_A + 1'b1;
											if (counter_A >= ((hdc_A * 2) - 1'b1))
												counter_A <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_A <= s_pos_amp_A - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_A <= (counter_A < hdc_A) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_A <= 1'b0;
											counter_A <= counter_A + 1'b1;
											if (counter_A >= ((hdc_A * 2) - 1'b1))
												counter_A <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_A <= (counter_A < hdc_A) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_A <= 1'b0;	
									counter_A <= counter_A + 1'b1;
									if (counter_A >= ((hdc_A * 2) - 1'b1))
										counter_A <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_A <= (counter_A < hdc_A) ? 1'b1 : 1'b0;
								end
							endcase
						else
							// STOP NOTE
							begin
								s_pos_amp_A <= pos_amp;
								countdown_A <= 1'b0;
								stop_A <= 1'b1;
								can_out_A <= 1'b1;	
								counter_A <= 1'd0;
								dac_out_A <= 1'b0;
							end
					end
				/**
				 *	B
				 */
				if (GPIO_0[8] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_B <= pos_amp;
						countdown_B <= 1'b0;
						stop_B <= 1'b0;
						can_out_B <= 1'b0;	
						counter_B <= counter_B + 1'b1;
						if (counter_B >= ((hdc_B * 2) - 1'b1))
							counter_B <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_B <= (counter_B < hdc_B) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_B == 1'b0)
							case(SW[1:0])
								2'b00: stop_B <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_B <= 1'b0;	
									counter_B <= counter_B + 1'b1;
									if (counter_B >= ((hdc_B * 2) - 1'b1))
										counter_B <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_B <= (counter_B < hdc_B) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_B <= 1'b1;
									if (fin_B == 1'b1)
											stop_B <= 1'b1;
									else if (s_half_B == 1'b1)
										begin
											
											can_out_B <= 1'b0;	
											counter_B <= counter_B + 1'b1;
											if (counter_B >= ((hdc_B * 2) - 1'b1))
												counter_B <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_B <= s_pos_amp_B - 16'h2BB1; // Subtract (amp/24 000) = 0x2BB1 on each 48kHz edge
											dac_out_B <= (counter_B < hdc_B) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_B <= 1'b0;
											counter_B <= counter_B + 1'b1;
											if (counter_B >= ((hdc_B * 2) - 1'b1))
												counter_B <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_B <= (counter_B < hdc_B) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_B <= 1'b0;	
									counter_B <= counter_B + 1'b1;
									if (counter_B >= ((hdc_B * 2) - 1'b1))
										counter_B <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_B <= (counter_B < hdc_B) ? 1'b1 : 1'b0;
								end
							endcase
						else
							// STOP NOTE
							begin
								s_pos_amp_B <= pos_amp;
								countdown_B <= 1'b0;
								stop_B <= 1'b1;
								can_out_B <= 1'b1;	
								counter_B <= 1'd0;
								dac_out_B <= 1'b0;
							end
					end
				/**
				 *	C high
				 */
				if (GPIO_0[9] == 1'b0)
					// LASERS OBSTRUCTED
					begin
						s_pos_amp_C_h <= pos_amp;
						countdown_C_h <= 1'b0;
						stop_C_h <= 1'b0;
						can_out_C_h <= 1'b0;	
						counter_C_h <= counter_C_h + 1'b1;
						if (counter_C_h >= ((hdc_C_h * 2) - 1'b1))
							counter_C_h <= 20'd0;
						write_audio_out <= 1'b1;
						dac_out_C_h <= (counter_C_h < hdc_C_h) ? 1'b1 : 1'b0;
					end
				else
					// SWITCH OFF
					begin
						if (stop_C_h == 1'b0)
							case(SW[1:0])
								2'b00: stop_C_h <= 1'b1;
								2'b01:
								// NON-STRING, SUSTAINED
								begin
									can_out_C_h <= 1'b0;	
									counter_C_h <= counter_C_h + 1'b1;
									if (counter_C_h >= ((hdc_C_h * 2) - 1'b1))
										counter_C_h <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_C_h <= (counter_C_h < hdc_C_h) ? 1'b1 : 1'b0;
								end
								2'b10:
								// STRING, NON-SUSTAINED
								begin
									countdown_C_h <= 1'b1;
									if (fin_C_h == 1'b1)
											stop_C_h <= 1'b1;
									else if (s_half_C_h == 1'b1)
										begin
											
											can_out_C_h <= 1'b0;	
											counter_C_h <= counter_C_h + 1'b1;
											if (counter_C_h >= ((hdc_C_h * 2) - 1'b1))
												counter_C_h <= 20'd0;
											write_audio_out <= 1'b1;
											if (audio_out_allowed == 1'b1)
												s_pos_amp_C_h <= s_pos_amp_C_h - 16'h2BB1; // Subtract (amp/24000) = 0x2BB1 on each 48kHz edge
											dac_out_C_h <= (counter_C_h < hdc_C_h) ? 1'b1 : 1'b0;
										end
									else
										begin
											can_out_C_h <= 1'b0;
											counter_C_h <= counter_C_h + 1'b1;
											if (counter_C_h >= ((hdc_C_h * 2) - 1'b1))
												counter_C_h <= 20'd0;
											write_audio_out <= 1'b1;
											dac_out_C_h <= (counter_C_h < hdc_C_h) ? 1'b1 : 1'b0;
										end
								end
								2'b11:
								// STRING, SUSTAINED
								begin
									can_out_C_h <= 1'b0;	
									counter_C_h <= counter_C_h + 1'b1;
									if (counter_C_h >= ((hdc_C_h * 2) - 1'b1))
										counter_C_h <= 20'd0;
									write_audio_out <= 1'b1;
									dac_out_C_h <= (counter_C_h < hdc_C_h) ? 1'b1 : 1'b0;
								end
							endcase
						else
							// STOP NOTE
							begin
								s_pos_amp_C_h <= pos_amp;
								countdown_C_h <= 1'b0;
								stop_C_h <= 1'b1;
								can_out_C_h <= 1'b1;	
								counter_C_h <= 1'd0;
								dac_out_C_h <= 1'b0;
							end
					end
			end
	end	

endmodule
