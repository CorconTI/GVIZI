module DAC4
(
input clk,
input CS,
//input mod,
input wire [31:0]data,

//бoutput ClkDac,
output [3:0]CsDac,
output dataDac,

output [8:0]states,
output [15:0]Dataout,
output [3:0]SPIcounter
);
assign Dataout = Dsd;
assign SPIcounter = counter;
assign states = state;
assign dataDac = Dsd[15];
reg [15:0]Dsd;
//добавить защелку для запуска машины состояний, проверить waveform1
wire [15:0]Mdata;		//шинна данных для мультиплексирования

reg CSr = 0;
always@(posedge clk, posedge CS)begin
if(CS)
	CSr <= 1;
else
if(state == IDLE)
	CSr <= 0;
	
end

always@(negedge clk)	//сдвиговый регистр spi
begin
if (wcount == 0)
		begin
			Dsd[15:1] <= Dsd[14:0];
			Dsd[0] <= 0;
		end
else
	Dsd<=Mdata;
end

enum int unsigned { IDLE = 0, WDATA0 = 2,  TDATA0= 4, WDATA1 = 8,TDATA1 = 16,WDATA2 = 32,TDATA2 = 64,WDATA3 = 128,TDATA3 = 256} state, next_state;

always_comb begin : next_state_logic
next_state = IDLE;
case(state)
	IDLE: next_state = WDATA0;

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
always@* begin
case(state)
	IDLE:CsDac = 4'b0000;
	WDATA0:begin	Mdata = {4'b0111,data[7:0],	4'b0}; CsDac = 4'b0;end	//мультиплексирование шины данных для каждого DAC
	WDATA1:begin 	Mdata = {4'b1111,data[15:8],	4'b0}; CsDac = 4'b0;end
	WDATA2:begin	Mdata = {4'b0111,data[23:16],	4'b0}; CsDac = 4'b0;end
	WDATA3:begin	Mdata = {4'b1111,data[31:24],	4'b0}; CsDac = 4'b0;end
	TDATA0:	CsDac = 4'b0001;	//первый канал
	TDATA1: 	CsDac = 4'b0010;	//второй канал
	TDATA2:	CsDac = 4'b0100;	//третий канал
	TDATA3:	CsDac = 4'b1000;	//четвертый канал
endcase
end

reg [3:0]counter = 15; wire wcount = ~(|counter[3:0]);
always_ff@(negedge clk or negedge CSr) begin
if(~CSr)
state <= IDLE;
else
begin
if(state == IDLE)
	state <= next_state;
if(wcount == 1)
	state <= next_state;
	if((state==WDATA0)||(state==WDATA1)||(state==WDATA2)||(state==WDATA3))
		state<=next_state;
		
	
end


end

always@(posedge clk)		//счетчик передачи пакета
begin
if((state == TDATA0)||(state == TDATA1)||(state == TDATA2)||(state == TDATA3))
		counter<=counter-1;
		else 
		counter<=15;
end


endmodule

