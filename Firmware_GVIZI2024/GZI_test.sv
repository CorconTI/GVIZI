module GZI_test
(
input i_clk_internal,
input i_clk_external,
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
output logic [3:0]o_ChExp,
input [3:0]i_ChExp,
output logic [3:0]o_ChExpLed,
input logic[3:0]i_ChExpLed,

output o_pin64,
output o_pin38,
output o_pin20,
output o_pin17

);


logic [3:0]GVIZIoutq;
logic l_startGZI_GVI, l_clk_channels;

wire [15:0]w_ChCount0,w_ChCount1, w_ChCount2,w_ChCount3;	//данные для каждого канала
wire w_mod,w_clk2,w_clk3;	//w_mod - режим работы 0/1 - GZI/GVI
wire [7:0]w_prescaller, w_ChEnable;
wire w_first_charge,discharge,startGZI;
wire [7:0] w_ChDAC0,w_ChDAC1,w_ChDAC2,w_ChDAC3;
wire [3:0]w_outCh;
wire w_Clk_mod;

reg r_start_latch, r_start_negedge; //защелка для сигнала запуска
logic [1:0]r_reset_output_ch0;
logic [1:0]r_reset_output_ch1;
logic [1:0]r_reset_output_ch2;
logic [1:0]r_reset_output_ch3;
logic [3:0]w_reset_output_ch;
logic [3:0]r_main_reset;
wire w_main_reset;
assign w_reset_output_ch[0] = &r_reset_output_ch0[1:0];
assign w_reset_output_ch[1] = &r_reset_output_ch1[1:0];
assign w_reset_output_ch[2] = &r_reset_output_ch2[1:0];
assign w_reset_output_ch[3] = &r_reset_output_ch3[1:0];
assign w_main_reset = (~(|w_ChEnable[3:0]))||(|r_reset_output_ch0[1:0])|(|r_reset_output_ch1[1:0])|(|r_reset_output_ch2[1:0])|(|r_reset_output_ch3[1:0]);



reg [5:0]i_clk_internal_dev = 0;
reg i_clk_internalDiv = 0;
reg [23:0]r_spi_reg=0;


//wire clk_int_devw = ~(|i_clk_internal_dev[3:0]);

//assign o_ChExp[3:0]= GVIZIoutq[3:0];
//assign o_ChExpLed[3:0] = GVIZIoutq[3:0];

assign o_GVIZIoutLed[3:0] = i_ChExpLed[3:0];

assign o_GZIMod = ~w_mod;
assign o_GVIMod = w_mod;

integer i;


assign o_GVIZIout[3:0] = GVIZIoutq[3:0];
always_comb
	begin
	for(i=0; i<4; i=i+1)
		if(GVIZIoutq[i]==1)
			begin
			o_ChExpLed[i] = 1;
			o_ChExp[i] = 1; 
			end
			else begin
			o_ChExpLed[i] = 1'bZ;
			o_ChExp[i] = 1'bZ;
			end
	

	end

//Увеличение длительности сигналов

//мультиплексирование для режимов работы
always_comb begin
	
	l_startGZI_GVI = startGZI;
	if(w_mod == 0) begin
	o_Ch_charge = w_outCh;
	GVIZIoutq = ~i_GziOutCpldIn; end
	else begin
	o_Ch_charge = 0;
	GVIZIoutq = w_outCh;
	end

end
assign l_clk_channels = i_clk_internal;
assign o_pin38 = w_clk3;
assign o_pin20 = w_first_charge;
assign o_pin17 = startGZI;
assign o_pin64 = r_start_latch;

//registers
reg [7:0]r_identificator = 8'hb0; //идентификатор устройства, в версии GVIZI2023T всегда отсылается ведущему
////////////////////////////////
fchd fchd(.i_clk(w_clk3),.i_start(r_start_latch),
			.i_reset(w_main_reset),
			.i_reset_ch(w_reset_output_ch),
			.o_first_charge(w_first_charge),.o_discharge(o_Ch_discharge),.o_startcounter(startGZI)); //блок первого заряда и разряда


ChCounter Ch0(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[0]),.i_start(l_startGZI_GVI),.i_first_charge(w_first_charge),.i_HighDel(|r_reset_output_ch0[1:0]),.i_GziOutCpldIn(i_GziOutCpldIn[0]),.i_mod(w_mod),.i_DATA(w_ChCount0),.o_out(w_outCh[0]));
ChCounter Ch1(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[1]),.i_start(l_startGZI_GVI),.i_first_charge(w_first_charge),.i_HighDel(|r_reset_output_ch1[1:0]),.i_GziOutCpldIn(i_GziOutCpldIn[1]),.i_mod(w_mod),.i_DATA(w_ChCount1),.o_out(w_outCh[1]));
ChCounter Ch2(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[2]),.i_start(l_startGZI_GVI),.i_first_charge(w_first_charge),.i_HighDel(|r_reset_output_ch2[1:0]),.i_GziOutCpldIn(i_GziOutCpldIn[2]),.i_mod(w_mod),.i_DATA(w_ChCount2),.o_out(w_outCh[2]));
ChCounter Ch3(.i_clk(w_clk3),.i_ChEnable(w_ChEnable[3]),.i_start(l_startGZI_GVI),.i_first_charge(w_first_charge),.i_HighDel(|r_reset_output_ch3[1:0]),.i_GziOutCpldIn(i_GziOutCpldIn[3]),.i_mod(w_mod),.i_DATA(w_ChCount3),.o_out(w_outCh[3]));

		
Memmory Memmory(.i_data(r_spi_reg),.o_mod(w_mod),.o_Clk_mod(w_Clk_mod),.o_presc(w_prescaller),.o_ChEnable(w_ChEnable[3:0]),
					.o_ChCountD0(w_ChCount0),.o_ChCountD1(w_ChCount1),.o_ChCountD2(w_ChCount2),.o_ChCountD3(w_ChCount3),
					.o_ChDacD0(w_ChDAC0),.o_ChDacD1(w_ChDAC1),.o_ChDacD2(w_ChDAC2),.o_ChDacD3(w_ChDAC3),.i_enable(i_SPI_CS),.i_clk(i_clk_internal)); 

DAC2X2 DAC2X2(.i_clk(i_clk_internal),.i_CS(i_SPI_CS),.i_data({w_ChDAC0[7:0],w_ChDAC1[7:0],w_ChDAC2[7:0],w_ChDAC3[7:0]}),.o_CsDac(o_DAC_CS),.o_dataDac(o_DAC_MOSI),.o_ClkDac(o_DAC_CLK));


prescallerV3 prescallerV3(.i_clk(l_clk_channels),.i_prescData(w_prescaller),.o_out_clkP1(w_clk3),.o_out_clkP2(w_clk2)); //out_clkP1 - короткий out_clkP2 - длинный

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


always_ff@(posedge i_clk_internal)begin	//блок удержания выходных сигналов разряда и формирование сигнала сброса для каждого канала
	
	if((GVIZIoutq[0]==1)&&(o_Ch_discharge[0]==1))
		r_reset_output_ch0 <= r_reset_output_ch0 + 1;
		else
		r_reset_output_ch0<=0;
	if((GVIZIoutq[1]==1)&&(o_Ch_discharge[1]==1))
		r_reset_output_ch1 <= r_reset_output_ch1 + 1;
		else
		r_reset_output_ch1<=0;
	if((GVIZIoutq[2]==1)&&(o_Ch_discharge[2]==1))
		r_reset_output_ch2 <= r_reset_output_ch2 + 1;
		else
		r_reset_output_ch2<=0;
	if((GVIZIoutq[3]==1)&&(o_Ch_discharge[3]==1))
		r_reset_output_ch3 <= r_reset_output_ch3 + 1;
		else
		r_reset_output_ch3<=0;
		
	end
	
endmodule 