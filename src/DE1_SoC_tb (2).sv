module DE1_SoC_tb();

	
	logic CLOCK_50, CLOCK2_50;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;

	logic [7:0] VGA_R;
	logic [7:0] VGA_G;
	logic [7:0] VGA_B;
	logic VGA_BLANK_N;
	logic VGA_CLK;
	logic VGA_HS;
	logic VGA_SYNC_N;
	logic VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	// I2C Audio/Video config interface
	logic FPGA_I2C_SCLK;
	logic FPGA_I2C_SDAT;
	// Audio CODEC
	logic AUD_XCK;
	logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic AUD_ADCDAT;
	logic AUD_DACDAT;
	
	// define parameters
	parameter T = 20;
	
	// instantiate module
   DE1_SoC dut (.CLOCK_50, .CLOCK2_50, .FPGA_I2C_SCLK, .FPGA_I2C_SDAT,
	.AUD_XCK, .AUD_DACLRCK, .AUD_ADCLRCK, .AUD_BCLK, .AUD_ADCDAT, .AUD_DACDAT,
                .KEY, .SW, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR, .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	
	// define simulated clock
	initial begin
		CLOCK_50 <= 0;
		forever	#(T/2)	CLOCK_50 <= ~CLOCK_50;
	end  // initial clock
	

	initial begin
		repeat(600)	@(posedge CLOCK_50);
		
		
		
		$stop; //End the simulation
	end
	
endmodule  // DE1_SoC_tb