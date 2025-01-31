// Quartus Prime Verilog Template
// Binary counter

module prescallerV3
#(parameter WIDTH=8)
(
	input i_clk,
	input [7:0]i_prescData,
	input i_enable,
	output o_out_clkP1,	//период равен частоте i_clk
	output o_out_clkP2	//
	
);
	reg [WIDTH-1:0] r_count=3;
	reg r_D_sinch=0;
	assign reset = o_out_clkP2;
	assign o_out_clkP2 = ~(|r_count[WIDTH-1:0]);
	

	always @ (posedge i_clk)
	begin
		if (reset)
			r_count <= i_prescData;
		else
//			if(i_enable==1)
			r_count <= r_count - 1;
	end
	
	assign o_out_clkP1 = ~r_D_sinch&o_out_clkP2;
	
	always_ff@(posedge i_clk)
	begin
	r_D_sinch<=o_out_clkP2;
	end
	
endmodule
