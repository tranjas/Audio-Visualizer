module volume_detector (writedata_right, clk_select, reset, vol_0, vol_1, vol_2, vol_3, vol_4, vol_5);
  logic [23:0] abs_data;
  input logic signed [23:0] writedata_right;
  input logic clk_select, reset;
  output logic vol_0, vol_1, vol_2, vol_3, vol_4, vol_5; 

  // abs_data is the absolute value of the writedata that is taken from the microphone
  assign abs_data = (writedata_right < 0) ? -1*(writedata_right) : writedata_right;

	// This always ff_block sends out status signals based on the range that the abs_data is in
	// volume will increase as the number increases. Only one status signal is true at one time.
  always_ff @(posedge clk_select) begin
    if (abs_data > 600000) begin
        vol_0 = 0;
        vol_1 = 0;
        vol_2 = 0;
        vol_3 = 0;
        vol_4 = 0;
        vol_5 = 1;
    end
    else if (abs_data > 500000) begin
        vol_0 = 0;
        vol_1 = 0;
        vol_2 = 0;
        vol_3 = 0;
        vol_4 = 1;
        vol_5 = 0;
    end
    else if (abs_data > 400000) begin
        vol_0 = 0;
        vol_1 = 0;
        vol_2 = 0;
        vol_3 = 1;
        vol_4 = 0;
        vol_5 = 0;
    end
    else if (abs_data > 300000) begin
        vol_0 = 0;
        vol_1 = 0;
        vol_2 = 1;
        vol_3 = 0;
        vol_4 = 0;
        vol_5 = 0;
    end
    else if (abs_data > 200000) begin
        vol_0 = 0;
        vol_1 = 1;
        vol_2 = 0;
        vol_3 = 0;
        vol_4 = 0;
        vol_5 = 0;
    end
    else if (abs_data > 100000) begin
        vol_0 = 1;
        vol_1 = 0;
        vol_2 = 0;
        vol_3 = 0;
        vol_4 = 0;
        vol_5 = 0;
    end
    // else begin
    //     vol_0 = 0;
    //     vol_1 = 0;
    //     vol_2 = 0;
    //     vol_3 = 1;
    //     vol_4 = 0;
    //     vol_5 = 0;
    // end
  end
endmodule