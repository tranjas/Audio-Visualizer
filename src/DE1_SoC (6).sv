module DE1_SoC (CLOCK_50, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT,
	AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT,
                KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

	input logic CLOCK_50, CLOCK2_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;

	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;

	logic reset;
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires
	logic read_ready, write_ready, read, write;
	logic signed [23:0] readdata_left, readdata_right;
  logic signed [23:0] writedata_left, writedata_right;
	logic signed [23:0] task2_left, task2_right, task3_left, task3_right, q;
	logic signed [23:0] noisy_left, noisy_right;
	
	logic [23:0] noise;
	noise_gen noise_generator (.clk(CLOCK_50), .en(read), .rst(reset), .out(noise));
	assign noisy_left = readdata_left + noise;
	assign noisy_right = readdata_right + noise;
	
	always_comb begin
		case(KEY[2:0])
			3'b110: begin // KEY0 outputs noise
				writedata_left = noisy_left;
				writedata_right = noisy_right;
			end
			3'b101: begin // KEY1 outputs task2 filtered noise
				writedata_left = task2_left;
				writedata_right = task2_right;
			end
			3'b011: begin // KEY2 outputs task3 filtered noise
				writedata_left = task3_left;
				writedata_right = task3_right;
			end
			default: begin // default output raw data
				writedata_left = readdata_left;
				writedata_right = readdata_right;
			end
		endcase
	end

	assign reset = ~KEY[3];
	assign {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = '1;
//	assign LEDR = SW;
	
	// only read or write when both are possible
	assign read = read_ready & write_ready;
	assign write = read_ready & write_ready;

  video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	

  logic vol_0, vol_1, vol_2, vol_3, vol_4, vol_5;
  
  	// Creates a divided clock
	parameter whichClock = 20;
	logic [31:0] div_clk; 
	clock_divider clkdiv (.clock(CLOCK_50), .divided_clocks(div_clk));
	logic clk_select;
	
// 	assign clk_select = CLOCK_50; //for simulation
	assign clk_select = div_clk[whichClock]; //for board
  
  // instaciates the volume_detector we created inputting microphone data and outputing status signals
  volume_detector det (.writedata_right, .clk_select, .reset, .vol_0, .vol_1, .vol_2, .vol_3, .vol_4, .vol_5);
  
//  // instanciates the stickman_ram that contains our stickman drawing
//  stickman_ram ram (.address, .clock(CLOCK_50), .data, .wren, .q(q_ram));
//  logic [9:0] address;
//  logic [301:0] data;
//  logic wren;
//  logic [301:0] q_ram;
//  logic read_address;

//	logic row_clock, address_clock;
//	logic [9:0] read_address;
//// this always_ff block will control the address changes based on the size of our image mif file
//	always_ff @(posedge CLOCK_50) begin
//		if (row_clock <= 640) begin
//			address_clock <= 0;
//			row_clock <= 0;
//		end else if (row_clock <= 639) begin
//			address_clock <= 1;
//			row_clock <= row_clock + 1;
//		end else
//			address_clock <= 0;
//			row_clock <= row_clock + 1;
//		end
//		
//		
//		if (read_address < 480 && address_clock == 1) begin
//			read_address <= real_address + 1;
//		end else if (read_address => 480 && address_clock == 1) begin
//			read_address <= 0;
//		end
//		
//		address <= read_address;
//	end

  // This always_ff block was used to help debug our code as it shows the level on the board instead
  // of using the vga screen, based on the volume, the number of lights will decrease/increase, it uses
  // the status signals that we created in the volume detector module
	always_ff @(posedge clk_select) begin
		if (vol_0) begin
			LEDR[0] <= 1;
			LEDR[1] <= 0;
			LEDR[2] <= 0;
			LEDR[3] <= 0;
			LEDR[4] <= 0;
			LEDR[5] <= 0;
		end
		
		if (vol_1) begin
			LEDR[0] <= 1;
			LEDR[1] <= 1;
			LEDR[2] <= 0;
			LEDR[3] <= 0;
			LEDR[4] <= 0;
			LEDR[5] <= 0;
		end
		
		if (vol_2) begin
			LEDR[0] <= 1;
			LEDR[1] <= 1;
			LEDR[2] <= 1;
			LEDR[3] <= 0;
			LEDR[4] <= 0;
			LEDR[5] <= 0;
		end
		
		if (vol_3) begin
			LEDR[0] <= 1;
			LEDR[1] <= 1;
			LEDR[2] <= 1;
			LEDR[3] <= 1;
			LEDR[4] <= 0;
			LEDR[5] <= 0;
		end
		
		if (vol_4) begin
			LEDR[0] <= 1;
			LEDR[1] <= 1;
			LEDR[2] <= 1;
			LEDR[3] <= 1;
			LEDR[4] <= 1;
			LEDR[5] <= 0;
		end
		
		if (vol_5) begin
			LEDR[0] <= 1;
			LEDR[1] <= 1;
			LEDR[2] <= 1;
			LEDR[3] <= 1;
			LEDR[4] <= 1;
			LEDR[5] <= 1;
		end
	end
	
	
	// This always ff block is how we draw the bars in the vga based on the volume status signals outputed by the volume
	// detector module. Based on the x and y values of the vga, we can change the color using coordinates in the comments
	// below, this code works similarly to the LEDR always_ff block.
   always_ff @(posedge CLOCK_50) begin
     if (vol_0) begin 
       if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
      if (x <= 110 || x >= 210 || y <= 410 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
    end 

     else if (vol_1) begin
		if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
       if (x > 110 && x < 210 && y < 390 && y > 330) begin
        // x = 110 - 210, y = 300 - 330 (green)
          r <= 8'h00;
          g <= 8'hff;
          b <= 8'h00;
      end
      if (x <= 110 || x >= 210 || y <= 330 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
     end

    
     if (vol_2) begin 
		 if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
       if (x > 110 && x < 210 && y < 390 && y > 330) begin
        // x = 110 - 210, y = 300 - 330 (green)
          r <= 8'h00;
          g <= 8'hff;
          b <= 8'h00;
      end
       if(x > 110 && x < 210 && y < 310 && y > 250) begin
        // x = 110 - 210, y = 310 - 250 (lime)
        r <= 8'h7b;
        g <= 8'hef;
        b <= 8'h10;
      end
      if (x <= 110 || x >= 210 || y <= 250 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
    end

     if (vol_3) begin
		 if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
       if (x > 110 && x < 210 && y < 390 && y > 330) begin
        // x = 110 - 210, y = 300 - 330 (green)
          r <= 8'h00;
          g <= 8'hff;
          b <= 8'h00;
      end
       if(x > 110 && x < 210 && y < 310 && y > 250) begin
        // x = 110 - 210, y = 310 - 250 (lime)
        r <= 8'h7b;
        g <= 8'hef;
        b <= 8'h10;
      end
       if (x > 110 && x < 210 && y < 230 && y > 170) begin
          // x = 110 - 210, y = 230 - 170 (yellow)
          r <= 8'hde;
          g <= 8'hff;
          b <= 8'h00;
        end
      if (x <= 110 || x >= 210 || y <= 170 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
     end
  
     if (vol_4) begin
		 if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
       if (x > 110 && x < 210 && y < 390 && y > 330) begin
        // x = 110 - 210, y = 300 - 330 (green)
          r <= 8'h00;
          g <= 8'hff;
          b <= 8'h00;
      end
       if(x > 110 && x < 210 && y < 310 && y > 250) begin
        // x = 110 - 210, y = 310 - 250 (lime)
        r <= 8'h7b;
        g <= 8'hef;
        b <= 8'h10;
      end
       if (x > 110 && x < 210 && y < 230 && y > 170) begin
          // x = 110 - 210, y = 230 - 170 (yellow)
          r <= 8'hde;
          g <= 8'hff;
          b <= 8'h00;
        end
       if (x > 110 && x < 210 && y < 150 && y > 90) begin
          // x = 110 - 210, y = 150 - 90 (orange)
          r <= 8'hff;
          g <= 8'hc5;
          b <= 8'h00;
       end
      if (x <= 110 || x >= 210 || y <= 90 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
     end
  
     if (vol_5) begin
		 if (x > 110 && x < 210 && y < 460 && y > 410) begin
         // x = 110 - 210, y = 460 - 410 (teal)
          r <= 8'h0b;
          g <= 8'h9c;
          b <= 8'h5d;
       end
       if (x > 110 && x < 210 && y < 390 && y > 330) begin
        // x = 110 - 210, y = 300 - 330 (green)
          r <= 8'h00;
          g <= 8'hff;
          b <= 8'h00;
      end
       if(x > 110 && x < 210 && y < 310 && y > 250) begin
        // x = 110 - 210, y = 310 - 250 (lime)
        r <= 8'h7b;
        g <= 8'hef;
        b <= 8'h10;
      end
       if (x > 110 && x < 210 && y < 230 && y > 170) begin
          // x = 110 - 210, y = 230 - 170 (yellow)
          r <= 8'hde;
          g <= 8'hff;
          b <= 8'h00;
        end
       if (x > 110 && x < 210 && y < 150 && y > 90) begin
          // x = 110 - 210, y = 150 - 90 (orange)
          r <= 8'hff;
          g <= 8'hc5;
          b <= 8'h00;
       end
       if (x > 110 && x < 210 && y < 70 && y > 10) begin
        // x = 110 - 210, y = 70 - 10 (red)
        r <= 8'hff;
        g <= 8'h00;
        b <= 8'h00;
     end
      if (x <= 110 || x >= 210 || y <= 10 || y >= 460) begin
         r <= 8'h00;
         g <= 8'h00;
         b <= 8'h00;
       end
   end
	
//	if (x > 215 && x < 517) begin
//		if(q_ram == 0) begin
//         // x = 110 - 210, y = 460 - 410 (teal)
//          r <= 8'h0b;
//          g <= 8'h00;
//          b <= 8'hff;
//       end else begin
//			r <= 8'h00;
//         g <= 8'h00;
//         b <= 8'h00;
//		 end
//	 end
   
  end
 

/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		1'b0,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		1'b0,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		1'b0,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule 