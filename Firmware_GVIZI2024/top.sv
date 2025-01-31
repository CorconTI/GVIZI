module top
(
input i_clk_internal,
input i_start,
input i_SPI_CS,
input i_SPI_CLK,
input i_SPI_MOSI,
input [3:0]i_GziOutCpldIn,
output o_SPI_MISO,
output logic [3:0]o_Ch_discharge,
output [1:0]o_DAC_CS,
output o_DAC_MOSI,
output o_DAC_CLK,
output logic [3:0]o_Ch_charge,
output [3:0]o_GVIZIout,
output [3:0]o_GVIZIoutLed,
output o_GZIMod,
output o_GVIMod,

//RC мультивибраторы
input [3:0]i_ChExp,
output logic [3:0]o_ChExpLed,
input logic[3:0]i_ChExpLed,


//output o_presc_clk,
output o_start_latch,
output o_main_reset,
output o_start_GZI

);


logic [3:0]GVIZIoutq;
logic w_startGVIZI, l_clk_channels;

wire [15:0]w_ChCount0,w_ChCount1, w_ChCount2,w_ChCount3;	//данные для каждого канала
wire w_mod,w_clk2,w_clk3;	//w_mod - режим работы 0/1 - GZI/GVI
wire [7:0]w_prescaller, w_ChEnable;
wire w_first_charge,discharge,startGZI;
wire [7:0] w_ChDAC0,w_ChDAC1,w_ChDAC2,w_ChDAC3;
wire [3:0]w_outCh;
wire w_Clk_mod;
wire w_prescaller_enable;

reg r_start_latch, r_start_negedge; //защелка для сигнала запуска
logic [3:0]r_reset_output_ch;
//reg [3:0]r_reset_ch_start=0; //регистр установки срабатывания канала для дальнейшей обработки сброса
logic [3:0]w_reset_output_ch;
//logic [3:0]r_main_reset;
wire w_main_reset;

//assign w_main_reset = (~(|w_ChEnable[3:0]))||(&r_reset_output_ch[3:0]);
assign o_main_reset = w_main_reset;


reg [5:0]i_clk_internal_dev = 0;
reg i_clk_internalDiv = 0;
reg [23:0]r_spi_reg=0;
//reg [3:0]r_latch_duration_out;//регистр для контроля длительности выходного импульса, необходим в режиме ГЗИ,
										//т.к для быстрых фронтов, Discharge формируется через ИЛИ напрямую от start_latch

//wire clk_int_devw = ~(|i_clk_internal_dev[3:0]);

//assign o_ChExp[3:0]= GVIZIoutq[3:0];
//assign o_ChExpLed[3:0] = GVIZIoutq[3:0];

assign o_GVIZIoutLed[3:0] = i_ChExpLed[3:0];

assign o_GZIMod = ~w_mod;
assign o_GVIMod = w_mod;

integer i;//переменная для циклов


assign o_GVIZIout[3:0] = GVIZIoutq[3:0]|i_ChExp[3:0]; //увеличение длительности
always_comb
	begin
	for(i=0; i<4; i=i+1)
		if(GVIZIoutq[i]==1)
			begin
			o_ChExpLed[i] = 1;
			end
			else begin
			o_ChExpLed[i] = 1'bZ;
			end
	

	end

//Увеличение длительности сигналов

//мультиплексирование для режимов работы
//в режиме ГЗИ выход делителя частоты должен постоянно подавать укороченную частоту на fchd для отслеживания запуска
//Выходы счетчиков должны быть мультиплексированы на выходы заряда
//аналоговая схема должна сгенерировать сигнал после конца работы счетчиков каналов
//сигнал i_GziOutCpldIn*** устанавливает защелки срабатывания каналов, для дальнейшего сброса
//сигнал сброса счетчиков каналов формируется отдельно для каждого из них для уменьшения среднего потребления
//как только счетчики сбрасываются, сигнал заряда пропадает
//главный сброс формируется только после срабатывания всех каналов, причем логика должна учитывать отключенные каналы
//главный сброс сбрасывает входную защелку запуска и блок fchd

//в режиме ГВИ блок делителя частоты prescallerV3 находится в режиме ожидания
//сигнал с защелки запуска является разрешением для тактирования делителя частоты
//как только придет сигнал запуска, одновременно с ним с неопределенностью 10нс начинают тактироваться счетчики каналов
//выход счетчиков мультиплексирован напрямую к усилителям
//сигналы сброса формируются из выходных сигналов
//как только сформировался главный сброс, сбрасывается основная защелка и соответственно, сбрасывается делитель частоты
//блок fchd в режиме ГВИ отключен и находится в режиме ожидания
//
always_comb begin
	
	
	if(w_mod == 0) begin
	w_startGVIZI = startGZI;
	w_prescaller_enable = 1;
	o_Ch_charge = w_outCh;
	GVIZIoutq = ~i_GziOutCpldIn; end
	else begin
	w_startGVIZI = i_start;
	w_prescaller_enable = r_start_latch;
	o_Ch_charge = 0;
	GVIZIoutq = w_outCh;
	end

end
assign l_clk_channels = i_clk_internal;
//assign o_presc_clk = w_clk3; //выход делителя
assign o_start_GZI = startGZI;//запуск счетчиков
assign o_start_latch = r_start_latch;//входная защелка для запуска

//registers
reg [7:0]r_identificator = 8'hb0; //идентификатор устройства, в версии GVIZI2023T всегда отсылается ведущему
////////////////////////////////
fchd fchd(.i_clk(w_clk3),.i_start(r_start_latch),//написать мультиплексор для отключения данного блока
			.i_reset(w_main_reset),
			.i_reset_ch(w_reset_output_ch),
			.o_first_charge(w_first_charge),.o_discharge(o_Ch_discharge),.o_startcounter(startGZI)); //блок первого заряда и разряда


ChCounter Ch0(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[0]),.i_start(w_startGVIZI),.i_first_charge(w_first_charge),.i_HighDel(w_reset_output_ch[0]),.i_GziOutCpldIn(i_GziOutCpldIn[0]),.i_mod(w_mod),.i_DATA(w_ChCount0),.o_out(w_outCh[0]));
ChCounter Ch1(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[1]),.i_start(w_startGVIZI),.i_first_charge(w_first_charge),.i_HighDel(w_reset_output_ch[1]),.i_GziOutCpldIn(i_GziOutCpldIn[1]),.i_mod(w_mod),.i_DATA(w_ChCount1),.o_out(w_outCh[1]));
ChCounter Ch2(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[2]),.i_start(w_startGVIZI),.i_first_charge(w_first_charge),.i_HighDel(w_reset_output_ch[2]),.i_GziOutCpldIn(i_GziOutCpldIn[2]),.i_mod(w_mod),.i_DATA(w_ChCount2),.o_out(w_outCh[2]));
ChCounter Ch3(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[3]),.i_start(w_startGVIZI),.i_first_charge(w_first_charge),.i_HighDel(w_reset_output_ch[3]),.i_GziOutCpldIn(i_GziOutCpldIn[3]),.i_mod(w_mod),.i_DATA(w_ChCount3),.o_out(w_outCh[3]));

		
Memmory Memmory(.i_data(r_spi_reg),.o_mod(w_mod),.o_Clk_mod(w_Clk_mod),.o_presc(w_prescaller),.o_ChEnable(w_ChEnable[3:0]),
					.o_ChCountD0(w_ChCount0),.o_ChCountD1(w_ChCount1),.o_ChCountD2(w_ChCount2),.o_ChCountD3(w_ChCount3),
					.o_ChDacD0(w_ChDAC0),.o_ChDacD1(w_ChDAC1),.o_ChDacD2(w_ChDAC2),.o_ChDacD3(w_ChDAC3),.i_enable(i_SPI_CS),.i_clk(i_clk_internal)); 

DAC2X2 DAC2X2(.i_clk(i_clk_internal),.i_CS(i_SPI_CS),.i_data({w_ChDAC0[7:0],w_ChDAC1[7:0],w_ChDAC2[7:0],w_ChDAC3[7:0]}),.o_CsDac(o_DAC_CS),.o_dataDac(o_DAC_MOSI),.o_ClkDac(o_DAC_CLK));


prescallerV3 prescallerV3(.i_clk(i_clk_internal),.i_prescData(w_prescaller),.i_enable(w_prescaller_enable),.o_out_clkP1(w_clk3),.o_out_clkP2(w_clk2)); //out_clkP1 - короткий out_clkP2 - длинный

//модуль сброса
reset_unit reset_unit(.i_clk(w_clk3),.i_channel_enable(w_ChEnable),.i_channel_gen_signal(o_GVIZIout),.i_channel_latch(o_Ch_discharge),
							.o_main_reset(w_main_reset),.o_reset_ch(w_reset_output_ch),.i_r_start_latch(r_start_latch));

always@(posedge i_SPI_CLK)begin
if(i_SPI_CS==0)
begin
r_spi_reg[23:1]<=r_spi_reg[22:0];
r_spi_reg[0]<=i_SPI_MOSI;
end
end

always_ff@(posedge i_start or posedge w_main_reset) begin
if(w_main_reset)
	r_start_latch<=0;
	else
	r_start_latch<=1;
end
/*
always_latch begin
	if(i_ChExp==0)
	r_latch_duration_out[3:0]=4'b0000;
	else
	if(gviZIoutq == 1)begin
	for(i=0;i<4;i++)begin
	r_latch_duration_out[i]=1;
	end	end
end
*/
	
endmodule 