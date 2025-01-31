module counter
(
input clk,
input [15:0]data,
output clk_o
);
assign clk_o = w1;

reg [15:0]D=0;

wire w1;

assign w1 = |(~D[15:0]);
always@(posedge clk)
begin
if(data==200)
	D<=100;
D<=D-1;
end

endmodule

