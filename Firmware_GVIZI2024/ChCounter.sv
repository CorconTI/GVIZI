module ChCounter(
input i_clk,
input i_ChEnable, //включение канала
//input enable,	 //разрешение тактирования канала
input i_start,
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
wire w_comb_reset;
reg r_D1=0; 

//assign o_test1 = (r_D2 == i_DATA);
assign o_out = r_outcount&i_ChEnable|(i_first_charge)&i_ChEnable&~r_D1, o_outreset = i_HighDel|w_comb_reset, wD1=r_D1;
//r_D1 в o_out стробирует нестабильность сигнала из-за интерференции с сигналами ch_charge других каналов, 
//из-за которых между генерацией двух ch_charge канала
//в момент времени срабатывания счетчиков других каналов формировался дополнительный 2ns импульс из-за которого значительно изменялась задержка
//Поскольку стробировать нужно именно сигнал первого заряда и блок fchd формирует сигнал запуска для r_D1 после формирования first_charge, 
//поэтому он стробируется инверсией r_D1
//выходной сигнал счетчика не стробируется r_D1, т.к r_D1 сбрасывается этим же сигналом
//assign out = (first_charge|outcount)&ChEnable, outreset = HighDel|comb_reset, wD1=D1; //was like this

always_comb
begin
if(i_mod == 0)
	w_comb_reset = ~i_GziOutCpldIn; //сигнал с выхода аналоговой схемы инвертированный
	else
	w_comb_reset = r_outcount;
	
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



always@(posedge i_clk)
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
endmodule
