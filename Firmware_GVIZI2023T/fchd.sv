module fchd(
input i_clk,
input i_start,
input i_reset,
input [3:0]i_reset_ch,
output o_first_charge,
output [3:0]o_discharge,
output o_startcounter
);


reg r_D1=0,r_D2=0;
reg [3:0]r_Dsd=0;
int i;
assign o_first_charge=~r_D2&i_start, o_startcounter=r_D2;

always_comb begin
for(i=0;i<4;i++)
	o_discharge[i]=(r_D1||i_start||r_Dsd[i]);
end
always_latch begin
for(i=0;i<4;i++)begin
if(i_start==1)
	r_Dsd[i] = 1;
if(i_reset_ch[i]==1)
	r_Dsd[i] = 0;
end
end
always@(posedge i_clk, posedge i_reset)
begin
if(i_reset==1)
r_D1<=0;
else
r_D1<=i_start;
end
always@(negedge i_clk, posedge i_reset)
begin
if(i_reset==1)
r_D2<=0;
else
r_D2<=r_D1;
end

/*
always@(posedge i_start, posedge i_reset)
begin
if(i_reset==1)
	r_Dsd = 0;
	else
	r_Dsd = 1;
end
always@(posedge i_clk, posedge i_reset)
begin
if(i_reset==1)
r_D1<=0;
else
r_D1<=i_start;
end
always@(negedge i_clk, posedge i_reset)
begin
if(i_reset==1)
r_D2<=0;
else
r_D2<=r_D1;
end
*/
endmodule
