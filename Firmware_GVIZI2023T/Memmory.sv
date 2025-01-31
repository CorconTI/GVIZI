module Memmory
#(parameter N=20)
(
input i_clk,
input i_enable,
input i_spi_done,

input [23:0]i_data,		//задержка мод 1 старшие 8 бит в DAC; младщие 8 в счетчики

output reg o_mod, //mod - режим работы 0/1 - GZI/GVI
output reg o_Clk_mod,	//режим тактирования 0 - internal i_clk; 1 - external i_clk
output reg [7:0]o_presc,
output reg [3:0]o_ChEnable,
output reg [15:0]o_ChCountD0,	//выходы на счетчики каналов
output reg [15:0]o_ChCountD1,
output reg [15:0]o_ChCountD2,
output reg [15:0]o_ChCountD3,
output reg [7:0]o_ChDacD0, o_ChDacD1, o_ChDacD2, o_ChDacD3
);
initial
begin
	o_mod = 0;
	o_Clk_mod = 0;
	o_presc [7:0] = 3;
	o_ChEnable[3:0] = 4'b1111;
	o_ChCountD0[15:0] = 16'h0001;
	o_ChCountD1[15:0] = 16'h0001;
	o_ChCountD2[15:0] = 16'h0001;
	o_ChCountD3[15:0] = 16'h0001;
	o_ChDacD0=0;
	o_ChDacD1=0;
	o_ChDacD2=0;
	o_ChDacD3=0;
end
//вид посылки - i_data[23:0] = {R/W->W*, 3'b0, addr[3:0], i_data[15:0]}; *R/W - не используется, всегда Write
wire [3:0]addr;
assign addr[3:0] = i_data [19:16]; //привязка к адресу регистра
reg renable;

always@(posedge i_enable or negedge i_clk)begin
if(i_enable==1)
	renable<=1;
	else
	renable<=0;
end
always_ff@(posedge i_clk)
begin
		if(renable == 1)
		case(addr)	//мультиплексирование данных для записи и считывания*
			0:
			begin
				//в будущем регистр для считывания версии устройства
			end
			1: 
				begin
				o_ChEnable[3:0]<=i_data[11:8]; 
				end
			2:
				begin
				o_mod<=i_data[0];
				o_Clk_mod<=i_data[4];
				end
			3:
				begin
				o_ChCountD0<=i_data[15:0];
				end
			4:
				begin
				o_ChDacD0<=i_data[7:0];
				end
			5:
				begin
				o_ChCountD1<=i_data[15:0];
				end
			6:
				begin
				o_ChDacD1<=i_data[7:0];
				end
			7:
				begin
				o_ChCountD2<=i_data[15:0];
				end
			8:
				begin
				o_ChDacD2<=i_data[7:0];
				end
			9:
				begin
				o_ChCountD3<=i_data[15:0];
				end
			10:
				begin
				o_ChDacD3<=i_data[7:0];
				end
			11:
				begin
				o_presc<=i_data[7:0];
				end
			endcase
end


endmodule
