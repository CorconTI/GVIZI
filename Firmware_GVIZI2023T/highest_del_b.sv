module highest_del_b
(
input clk,
input reset,
input [15:0]DATA0,
input [15:0]DATA1,
input [15:0]DATA2,
input [15:0]DATA3,
output wire [1:0]out
);

assign out = state1;

reg DEnd=0;
reg [1:0]Dcounter=0;
reg [1:0]state1;

wire [15:0]A,B;

always@*
begin
if(state1 == 0)
begin
A = DATA0;
B = DATA1;
end
if(state1 == 1)
begin
A = DATA1;
B = DATA2;
end
if(state1 == 2)
begin
A = DATA2;
B = DATA3;
end
if(state1 == 3)
begin

end
end
 
always@(posedge clk)
begin
if(DEnd==0)
	begin
		case (state1)
		0:
		if(A<B)
			state1<=1;
		1:
		if(A<B)
			state1<=2;
		2:
		if(A<B)
			state1<=3;
		3:
			if(Dcounter == 3)
				DEnd <= 1;
		endcase
	end
if(reset == 0)
	DEnd <=0;
end



endmodule
