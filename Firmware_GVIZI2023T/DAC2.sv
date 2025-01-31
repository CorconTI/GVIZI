module DAC2
(
input clk,
input CS,
input mod,
input wire [15:0]data,

output ClkDac,
output [1:0]CsDac,
output dataDac,

output [3:0]states
);
assign states = state;
assign dataDac = Dsd[15];
reg [15:0]Dsd;
//добавить защелку для запуска машины состояний, проверить waveform1
wire [15:0]Mdata;		//шинна данных для мультиплексирования

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

enum int unsigned { IDLE = 0, WDATA0 = 2,  TDATA0= 4, WDATA1 = 8,TDATA1 = 16} state, next_state;

always_comb begin : next_state_logic
next_state = IDLE;
case(state)
IDLE: next_state = WDATA0;

WDATA0: next_state = TDATA0;
TDATA0: next_state = WDATA1;

WDATA1: next_state = TDATA1;
TDATA1: next_state = IDLE;

endcase
end
always@* begin
case(state)
IDLE:CsDac = 4'b0000;
WDATA0:begin	Mdata = {4'b0111,data[7:0],	4'b0}; CsDac = 4'b0000;end	//мультиплексирование шины данных для каждого DAC
WDATA1:begin 	Mdata = {4'b1111,data[15:8],	4'b0}; CsDac = 4'b0000;end
TDATA0:	CsDac = 4'b0001;	//первый канал
TDATA1: 	CsDac = 4'b0010;	//второй канал
endcase
end

reg [4:0]counter = 16; wire wcount = ~(|counter[4:0]);
always_ff@(negedge clk or negedge CS) begin
if(~CS)
state <= IDLE;
else
begin
if(state == IDLE)
	state <= next_state;
if(wcount == 1)
	state <= next_state;
	if((state==WDATA0)||(state==WDATA1))
		state<=next_state;
		
	
end


end

always@(posedge clk)		//счетчик передачи пакета
begin
if((state == TDATA0)||(state == TDATA1))
		counter<=counter-1;
		else 
		counter<=16;
end


endmodule

