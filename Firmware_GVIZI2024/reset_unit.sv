module reset_unit
(
input i_clk,
input i_r_start_latch,
input [3:0]i_channel_enable,
input [3:0]i_channel_gen_signal,
input [3:0]i_channel_latch,

output o_main_reset,
output [3:0]o_reset_ch
);
int i;
reg [3:0]r_reset_ch=4'b0000;
reg [3:0]r_reset_ch_delay=4'b0000;
reg [2:0]r_reset_delay=3'b000;
reg r_reset_start_latch;
assign w_main_reset = r_reset_delay[2];
//assign w_main_reset = ~(|i_channel_enable[3:0])|(&o_reset_ch[3:0]);
assign o_reset_ch[3:0] = r_reset_ch_delay[3:0]; 
assign o_main_reset = w_main_reset;

always@(posedge i_channel_gen_signal[0] or posedge w_main_reset)begin
	if(w_main_reset)
		r_reset_ch[0]=0;
		else
			if(i_channel_latch[0]==1)
			if(i_channel_gen_signal[0]==1)
				r_reset_ch[0]<=1;
end

always@(posedge i_channel_gen_signal[1] or posedge w_main_reset)begin
	if(w_main_reset)
		r_reset_ch[1]=0;
		else
			if(i_channel_latch[1]==1)
			if(i_channel_gen_signal[1]==1)
				r_reset_ch[1]<=1;
end

always@(posedge i_channel_gen_signal[2] or posedge w_main_reset)begin
	if(w_main_reset)
		r_reset_ch[2]=0;
		else
			if(i_channel_latch[2]==1)
			if(i_channel_gen_signal[2]==1)
				r_reset_ch[2]<=1;
end

always@(posedge i_channel_gen_signal[3] or posedge w_main_reset)begin
	if(w_main_reset)
		r_reset_ch[3]=0;
		else
			if(i_channel_latch[3]==1)
			if(i_channel_gen_signal[3]==1)
				r_reset_ch[3]<=1;
end

wire [3:0]w_reset_channel;
always_comb begin
	for(i=0;i<4;i++)begin
		//w_reset_channel[i] = r_reset_ch[i]&~i_channel_gen_signal[i]|~i_channel_enable[i];
		w_reset_channel[i] = r_reset_ch[i]|~i_channel_enable[i];
	end
end
always_ff@(posedge i_clk)begin
	r_reset_delay[0]<=&w_reset_channel[3:0];
	r_reset_delay[2:1]<=r_reset_delay[1:0];
end
always_ff@(negedge i_clk)begin
r_reset_ch_delay[3:0]<=r_reset_ch[3:0];
end
always_ff@(posedge i_clk)begin
if((r_reset_delay[1:0]==2'b00)&(r_reset_delay[3]==1))
	r_reset_start_latch<=1;
if(i_r_start_latch == 0)
	r_reset_start_latch<=0;
end
endmodule
