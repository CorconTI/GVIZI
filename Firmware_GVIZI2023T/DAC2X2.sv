module DAC2X2
(
input i_clk,	//10-20MHz
input i_CS,
//input mod,
input wire [31:0]i_data,

output o_ClkDac,
output logic [1:0]o_CsDac,
output o_dataDac
//output [15:0]Dataout, //отладка

//output [3:0]SPIcounter, //отладка
//output [8:0]states		//отладка
);
//assign Dataout = r_Dsd;
//assign SPIcounter = counter;
//assign states = state;
reg [15:0]r_Dsd;
reg [15:0]r_Mdata;		//шинна данных для мультиплексирования
reg [4:0]r_counter_bit = 15,counter_clk; wire w_count = ~(|r_counter_bit[3:0]),wcount_clk=~(|counter_clk[4:0]);
reg r_count_clk_h;

//enum int unsigned { IDLE = 0, START = 2, WDATA0 = 4,  TDATA0= 8, WDATA1 = 16,TDATA1 = 32,WDATA2 = 64,TDATA2 = 128,WDATA3 = 256,TDATA3 = 512} state, next_state;
enum int unsigned { IDLE, START, WDATA0,  TDATA0, WDATA1,TDATA1,WDATA2,TDATA2,WDATA3,TDATA3} state, next_state;
assign o_dataDac = r_Dsd[15];


//добавить защелку для запуска машины состояний, проверить waveform1

always_comb begin
if(state==IDLE)
	o_ClkDac = 0;
	else
	o_ClkDac = r_count_clk_h;
end

always@(negedge r_count_clk_h)	//сдвиговый регистр spi
begin
if ((state==WDATA0)||(state==WDATA1)||(state==WDATA2)||(state==WDATA3))begin
	r_Dsd[15:0]<=r_Mdata[15:0];
	r_counter_bit<=15;
	end
else
	begin
	r_Dsd[15:1] <= r_Dsd[14:0];
	r_Dsd[0] <= 0;
	r_counter_bit<=r_counter_bit-1;
	end
end



always_comb begin : next_state_logic
next_state = IDLE;
case(state)
IDLE: next_state = IDLE;
START: next_state = WDATA0;

WDATA0: next_state = TDATA0;
TDATA0: next_state = WDATA1;

WDATA1: next_state = TDATA1;
TDATA1: next_state = WDATA2;

WDATA2: next_state = TDATA2;
TDATA2: next_state = WDATA3;

WDATA3: next_state = TDATA3;
TDATA3: next_state = IDLE;

endcase
end
always_ff@* begin
case(state)
IDLE:o_CsDac = 2'b11;
START:o_CsDac = 2'b11;
WDATA0:begin	r_Mdata = {4'b0111,i_data[7:0],		4'b11}; o_CsDac = 2'b11;end//мультиплексирование шины данных для каждого DAC
WDATA1:begin 	r_Mdata = {4'b1111,i_data[15:8],		4'b11}; o_CsDac = 2'b11;end
WDATA2:begin	r_Mdata = {4'b0111,i_data[23:16],	4'b11}; o_CsDac = 2'b11;end
WDATA3:begin	r_Mdata = {4'b1111,i_data[31:24],	4'b11}; o_CsDac = 2'b11;end
TDATA0:begin	r_Mdata = {4'b0111,i_data[7:0],		4'b11}; o_CsDac = 2'b01;end//первый канал //при недостатке логических элементов можно убрать зануление r_Mdata и 
TDATA1:begin 	r_Mdata = {4'b1111,i_data[15:8],		4'b11}; o_CsDac = 2'b01;end//второй канал // получить дополнительно 9 логических элементов
TDATA2:begin	r_Mdata = {4'b0111,i_data[23:16],	4'b11}; o_CsDac = 2'b10;end//третий канал // единственное назначение этих конструкций заключается в контролируемом изменении
TDATA3:begin	r_Mdata = {4'b1111,i_data[31:24],	4'b11}; o_CsDac = 2'b10;end//четвертый канал //шины данных для ципов в моменты передачи, что не существенно.
default:begin	r_Mdata = 0;										  o_CsDac = 2'b11;end
endcase
end


always@(posedge i_clk)begin
	counter_clk<=counter_clk+1;
	if(counter_clk>=16)
		r_count_clk_h<=1;
		else
		r_count_clk_h<=0;
end

always@(negedge wcount_clk)
	begin

	if(i_CS==0)
		state<=START;
	if((state==WDATA0)||(state==WDATA1)||(state==WDATA2)||(state==WDATA3))
		state<=next_state;
		if(r_counter_bit==0)
			state<=next_state;
	
		
	end
endmodule

