//попытка переписать складывающие счетчики на выитающие, неудачная
module ChCounter_subt(
input i_clk,
input i_ChEnable, //включение канала
//input enable,	 //разрешение тактирования канала
input i_start,		//запуск счетчиков, формируется схемой заряда/разряда
input i_first_charge,
input i_HighDel,
input i_GziOutCpldIn,
input i_mod, //режим работы '0' - ГЗИ; '1' - ГВИ
input [15:0]i_DATA,
output o_out,
output o_outreset,

output wD1, //отладка
output o_test1

);
reg [15:0]r_D2=1;
reg r_outcount=0;
wire w_outcount;
wire w_comb_reset;
reg r_D1=0;
reg l_dout=0;
assign w_outcount = ~(|r_D2[15:0]);
assign o_out = (i_first_charge|l_dout)&i_ChEnable, o_outreset = i_HighDel|w_comb_reset, wD1=r_D1;


always_comb
begin
if(i_mod == 0)
	w_comb_reset = ~i_GziOutCpldIn; //сигнал с выхода аналоговой схемы инвертированный
	else
	w_comb_reset = w_outcount;
	
end
always@(posedge i_start or posedge o_outreset) //асинхронный сброс, синхронная установка по разрешению
begin
if(o_outreset == 1)
	r_D1<=0;
	else
	begin
	if(i_ChEnable==1)
	begin
		r_D1<=i_start;
	end
	end
end

/*

always@(posedge (i_start|o_outreset)&i_ChEnable, posedge o_out)
begin
if(o_out==1)
r_D1<=0;
else
r_D1<=i_start;
end
*/
/*
always@(negedge i_clk)
begin
//if(enable == 0)//включение тактирования, закоментированно, т.к неизвестно дает ли преимущесво выборка тактового сигнала с помощью сигнала разрешения
if(r_D1)
r_D2<=r_D2+1;
else begin
r_D2<=0;
r_outcount <=0;
end
if(r_D2 == i_DATA)
	r_outcount <=1;
end
*/
always@(negedge i_clk)
begin
//if(enable == 0)//включение тактирования, закоментированно, т.к неизвестно дает ли преимущесво выборка тактового сигнала с помощью сигнала разрешения
if(r_D1)
r_D2<=r_D2-1;
else begin
r_D2<=i_DATA;
end
end

always_latch begin
if(w_outcount == 1)
	l_dout = 1;
if(o_outreset == 0)
	l_dout = 0;
	end

endmodule
