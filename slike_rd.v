/**
 *	slike_rd_v1.1.01_sensors
 *	
 *	by Graham Sider
 *	& Michael Hong
 *	
 *	UofT 2T0
 *	ECE241 2017
 */

module slike_rd(
	reset,
	CLOCK_50,
	max_count,
	countdown,
	
	fin,
	half
);
	
	input reset, CLOCK_50;
	input [25:0] max_count;
	input countdown;
	
	reg [25:0] counter;
	output reg fin;
	output reg half;
	
	always@(posedge CLOCK_50)
	begin
		if (countdown == 1'b1)
			begin
				if (reset == 1'b1)
					counter <= max_count;
				if (counter < 26'd25000000) // counter < (max_count/2)
					half <= 1'b1;
				if (counter < 26'd1)
					fin <= 1'b1;
				else
					counter <= counter - 1'b1;
			end
		else
			begin
				counter <= max_count;
				fin <= 1'b0;
				half <= 1'b0;
			end
	end
	
endmodule

