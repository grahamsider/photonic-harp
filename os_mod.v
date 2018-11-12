/**
 *	os_mod_v4_sensor
 *	
 *	by Graham Sider
 *	& Michael Hong
 *	
 *	UofT 2T0
 *	ECE241 2017
 */



/**
 *	Octave/semitone modulation module
 */



module os_mod(
	reset,		// SW[9]
	octave,		// KEY[3:0]
	semi,		// SW[8] -- On = go up or down a semitone
	s_up_down,	// SW[7] -- High = up a semitone, low = down a semitone
	
	// Half duty cycles of each note
	hdc_C,
	hdc_D,
	hdc_E,
	hdc_F,
	hdc_G,
	hdc_A,
	hdc_B,
	hdc_C_h // High C
);
	
	input reset;		// SW[9]
	input [3:0] octave;	// KEY[3:0]
	input semi;			// SW[8] -- On = go up or down a semitone
	input s_up_down;	// SW[7] -- High = up a semitone, low = down a semitone
	
	// Half duty cycle definitions
	output reg [19:0] hdc_C;
	output reg [19:0] hdc_D;
	output reg [19:0] hdc_E;
	output reg [19:0] hdc_F;
	output reg [19:0] hdc_G;
	output reg [19:0] hdc_A;
	output reg [19:0] hdc_B;
	output reg [19:0] hdc_C_h; // High C
	
	// Determine octave
	reg set_o2;
	reg set_o3;
	reg set_o4;
	reg set_o5;
	reg set_o6;
	
	// Determine octave
	always@(*)
	begin
		if (reset == 1'b1)			// C4
			begin
				set_o2 <= 1'b0;
				set_o3 <= 1'b0;
				set_o4 <= 1'b1;
				set_o5 <= 1'b0;
				set_o6 <= 1'b0;
			end
		else if (octave[0] == 1'b0)	// C2
			begin
				set_o2 <= 1'b1;
				set_o3 <= 1'b0;
				set_o4 <= 1'b0;
				set_o5 <= 1'b0;
				set_o6 <= 1'b0;
			end
		else if (octave[1] == 1'b0)	// C3
			begin
				set_o2 <= 1'b0;
				set_o3 <= 1'b1;
				set_o4 <= 1'b0;
				set_o5 <= 1'b0;
				set_o6 <= 1'b0;
			end
		else if (octave[2] == 1'b0)	// C5
			begin
				set_o2 <= 1'b0;
				set_o3 <= 1'b0;
				set_o4 <= 1'b0;
				set_o5 <= 1'b1;
				set_o6 <= 1'b0;
			end
		else if (octave[3] == 1'b0)	// C6
			begin
				set_o2 <= 1'b0;
				set_o3 <= 1'b0;
				set_o4 <= 1'b0;
				set_o5 <= 1'b0;
				set_o6 <= 1'b1;
			end
		else 	// NOTE: INFERS A LATCH
			begin
				set_o2 <= set_o2;
				set_o3 <= set_o3;
				set_o4 <= set_o4;
				set_o5 <= set_o5;
				set_o6 <= set_o6;
			end
	end
		

	// Set half duty cycle of each note depnding on octave/semi on or off
	always@(*)
	begin
	
		// No semitone variation
		if (semi == 1'b0)
			begin
				if (set_o4 == 1'b1) 			// C4
					begin
						hdc_C <= 20'd95556;
						hdc_D <= 20'd85131;
						hdc_E <= 20'd75843;
						hdc_F <= 20'd71586;
						hdc_G <= 20'd63776;
						hdc_A <= 20'd56818;
						hdc_B <= 20'd50619;
						hdc_C_h <= 20'd47778; 	// High C
					end
				else if (set_o2 == 1'b1)		// C2
					begin
						hdc_C <= 20'd382228;
						hdc_D <= 20'd340525;
						hdc_E <= 20'd303372;
						hdc_F <= 20'd286346;
						hdc_G <= 20'd255105;
						hdc_A <= 20'd227273;
						hdc_B <= 20'd202477;
						hdc_C_h <= 20'd191113; 	// High C
					end
				else if (set_o3 == 1'b1)		// C3
					begin
						hdc_C <= 20'd191113;
						hdc_D <= 20'd170263;
						hdc_E <= 20'd151686;
						hdc_F <= 20'd143173;
						hdc_G <= 20'd127552;
						hdc_A <= 20'd113636;
						hdc_B <= 20'd101238;
						hdc_C_h <= 20'd95556; 	// High C
					end
				else if (set_o5 == 1'b1) 		// C5
					begin
						hdc_C <= 20'd47778;
						hdc_D <= 20'd42566;
						hdc_E <= 20'd37922;
						hdc_F <= 20'd35793;
						hdc_G <= 20'd31888;
						hdc_A <= 20'd28409;
						hdc_B <= 20'd25310;
						hdc_C_h <= 20'd23889; 	// High C
					end
				else if (set_o6 == 1'b1)		// C6
					begin
						hdc_C <= 20'd23889;
						hdc_D <= 20'd21283;
						hdc_E <= 20'd18961;
						hdc_F <= 20'd17897;
						hdc_G <= 20'd15944;
						hdc_A <= 20'd14205;
						hdc_B <= 20'd12655;
						hdc_C_h <= 20'd11945; 	// High C
					end
				else							// C4
					begin
						hdc_C <= 20'd95556;
						hdc_D <= 20'd85131;
						hdc_E <= 20'd75843;
						hdc_F <= 20'd71586;
						hdc_G <= 20'd63776;
						hdc_A <= 20'd56818;
						hdc_B <= 20'd50619;
						hdc_C_h <= 20'd47778; 	// High C
					end
			end
			
		// Down one semitone
		else if ((semi == 1'b1) && (s_up_down == 1'b0))
			begin
				if (set_o4 == 1'b1) 			// C4 flat
					begin
						hdc_C <= 20'd101238;	// B3
						hdc_D <= 20'd90193;		// C#4/Db4
						hdc_E <= 20'd80353;		// D#4/Eb4
						hdc_F <= 20'd75843;		// E4
						hdc_G <= 20'd67569;		// F#4/Gb4
						hdc_A <= 20'd60197;		// G#4/Ab4
						hdc_B <= 20'd53629;		// A#4/Bb4
						hdc_C_h <= 20'd50619; 	// B4 -- High C
					end
				else if (set_o2 == 1'b1)		// C2 flat
					begin
						hdc_C <= 20'd404957;
						hdc_D <= 20'd360771;		
						hdc_E <= 20'd321411;
						hdc_F <= 20'd303372;
						hdc_G <= 20'd270273;
						hdc_A <= 20'd240787;
						hdc_B <= 20'd214517;
						hdc_C_h <= 20'd202477; 	// High C
					end
				else if (set_o3 == 1'b1)		// C3 flat
					begin
						hdc_C <= 20'd202477;
						hdc_D <= 20'd180387;
						hdc_E <= 20'd160707;
						hdc_F <= 20'd151686;
						hdc_G <= 20'd135137;
						hdc_A <= 20'd120394;
						hdc_B <= 20'd107258;
						hdc_C_h <= 20'd101238; 	// High C
					end
				else if (set_o5 == 1'b1)		// C5 flat
					begin
						hdc_C <= 20'd50619;
						hdc_D <= 20'd45097;
						hdc_E <= 20'd40177;
						hdc_F <= 20'd37922;
						hdc_G <= 20'd33784;
						hdc_A <= 20'd30098;
						hdc_B <= 20'd26815;
						hdc_C_h <= 20'd25310; 	// High C
					end
				else if (set_o6 == 1'b1)		// C6 flat
					begin
						hdc_C <= 20'd25310;
						hdc_D <= 20'd22548;
						hdc_E <= 20'd20088;
						hdc_F <= 20'd18961;
						hdc_G <= 20'd16892;
						hdc_A <= 20'd15049;
						hdc_B <= 20'd13407;
						hdc_C_h <= 20'd12655; 	// High C
					end
				else							// C4 flat
					begin
						hdc_C <= 20'd101238;	// B3
						hdc_D <= 20'd90193;		// C#4/Db4
						hdc_E <= 20'd80353;		// D#4/Eb4
						hdc_F <= 20'd75843;		// E4
						hdc_G <= 20'd67569;		// F#4/Gb4
						hdc_A <= 20'd60197;		// G#4/Ab4
						hdc_B <= 20'd53629;		// A#4/Bb4
						hdc_C_h <= 20'd50619; 	// B4 -- High C
					end
			end
			
		// Up one semitone
		else if ((semi == 1'b1) && (s_up_down == 1'b1))
			begin
				if (set_o4 == 1'b1) 			// C4 sharp
					begin
						hdc_C <= 20'd90193;		// C#4
						hdc_D <= 20'd80353;		// D#4
						hdc_E <= 20'd71586;		// F4
						hdc_F <= 20'd67569;		// F#4
						hdc_G <= 20'd60197;		// G#4
						hdc_A <= 20'd53629;		// A#4
						hdc_B <= 20'd47778;		// C5
						hdc_C_h <= 20'd45097; 	// C#5 -- High C
					end
				else if (set_o2 == 1'b1)		// C2 sharp
					begin
						hdc_C <= 20'd360771;
						hdc_D <= 20'd321411;
						hdc_E <= 20'd286346;
						hdc_F <= 20'd270273;
						hdc_G <= 20'd240787;
						hdc_A <= 20'd214517;
						hdc_B <= 20'd191113;
						hdc_C_h <= 20'd180387; 	// High C
					end
				else if (set_o3 == 1'b1)		// C3 sharp
					begin
						hdc_C <= 20'd180387;
						hdc_D <= 20'd160707;
						hdc_E <= 20'd143173;
						hdc_F <= 20'd135137;
						hdc_G <= 20'd120394;
						hdc_A <= 20'd107258;
						hdc_B <= 20'd95556;
						hdc_C_h <= 20'd90193; 	// High C
					end
				else if (set_o5 == 1'b1)		// C5 sharp
					begin
						hdc_C <= 20'd45097;
						hdc_D <= 20'd40177;
						hdc_E <= 20'd35793;
						hdc_F <= 20'd33784;
						hdc_G <= 20'd30098;
						hdc_A <= 20'd26815;
						hdc_B <= 20'd23889;
						hdc_C_h <= 20'd22548; 	// High C
					end
				else if (set_o6 == 1'b1)		// C6 sharp
					begin
						hdc_C <= 20'd22548;
						hdc_D <= 20'd20088;
						hdc_E <= 20'd17897;
						hdc_F <= 20'd16892;
						hdc_G <= 20'd15049;
						hdc_A <= 20'd13407;
						hdc_B <= 20'd11945;
						hdc_C_h <= 20'd11274; 	// High C
					end
				else							// C4 sharp
					begin
						hdc_C <= 20'd95556;
						hdc_D <= 20'd85131;
						hdc_E <= 20'd75843;
						hdc_F <= 20'd71586;
						hdc_G <= 20'd63776;
						hdc_A <= 20'd56818;
						hdc_B <= 20'd50619;
						hdc_C_h <= 20'd47778; 	// High C
					end
			end
			
		// To not infer a latch: default = no semitone variation
		else
			begin
				if (set_o4 == 1'b1) 			// C4
					begin
						hdc_C <= 20'd95556;
						hdc_D <= 20'd85131;
						hdc_E <= 20'd75843;
						hdc_F <= 20'd71586;
						hdc_G <= 20'd63776;
						hdc_A <= 20'd56818;
						hdc_B <= 20'd50619;
						hdc_C_h <= 20'd47778; 	// High C
					end
				else if (set_o2 == 1'b1)		// C2
					begin
						hdc_C <= 20'd382228;
						hdc_D <= 20'd340525;
						hdc_E <= 20'd303372;
						hdc_F <= 20'd286346;
						hdc_G <= 20'd255105;
						hdc_A <= 20'd227273;
						hdc_B <= 20'd202477;
						hdc_C_h <= 20'd191113; 	// High C
					end
				else if (set_o3 == 1'b1)		// C3
					begin
						hdc_C <= 20'd191113;
						hdc_D <= 20'd170263;
						hdc_E <= 20'd151686;
						hdc_F <= 20'd143173;
						hdc_G <= 20'd127552;
						hdc_A <= 20'd113636;
						hdc_B <= 20'd101238;
						hdc_C_h <= 20'd95556; 	// High C
					end
				else if (set_o5 == 1'b1)		// C5
					begin
						hdc_C <= 20'd47778;
						hdc_D <= 20'd42566;
						hdc_E <= 20'd37922;
						hdc_F <= 20'd35793;
						hdc_G <= 20'd31888;
						hdc_A <= 20'd28409;
						hdc_B <= 20'd25310;
						hdc_C_h <= 20'd23889; 	// High C
					end
				else if (set_o6 == 1'b1)		// C6
					begin
						hdc_C <= 20'd23889;
						hdc_D <= 20'd21283;
						hdc_E <= 20'd18961;
						hdc_F <= 20'd17897;
						hdc_G <= 20'd15944;
						hdc_A <= 20'd14205;
						hdc_B <= 20'd12655;
						hdc_C_h <= 20'd11945; 	// High C
					end
				else							// C4
					begin
						hdc_C <= 20'd95556;
						hdc_D <= 20'd85131;
						hdc_E <= 20'd75843;
						hdc_F <= 20'd71586;
						hdc_G <= 20'd63776;
						hdc_A <= 20'd56818;
						hdc_B <= 20'd50619;
						hdc_C_h <= 20'd47778; 	// High C
					end
				
			end
		
	end

	
	
endmodule
