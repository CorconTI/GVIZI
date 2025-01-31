module InputPrescV1
(
input clk,
input mod, // GZI/GVI 0/1
input [3:0]presc,
output out
);

reg [17:0]D1=9;	//счетчик ГВИ
reg [1:0]D2=3;	//счетчик ГЗИ


wire w2 = ~(|D2[1:0]), w1 = ~(|D1[17:0]), w12 = clk&w1,w22 = w2&clk;	//при счете до 0 формируется '1' на выходе
wire clk1,clk2,prescout;

assign out = w12^w22;

always@*
begin
	case(mod)
	0:	clk1 = clk; // GZI
	1:	clk2 = clk;	//GVI
	endcase
end

always@(negedge clk1)begin	//GZI f = 25 MHz
if(w22==1)
D2<=3;
else 
D2<=D2-1;
end

always@(negedge clk2)begin	//GVI f = 10 MHz ... 304 Hz
if(w12==1)
begin
case(presc) //тактовый импульс каждый раз делиться на 2
0:	D1<=9;
1:	D1<=19;
2:	D1<=39;
3:	D1<=79;
4:	D1<=159;
5:	D1<=319;
6:	D1<=639;
7:	D1<=1279;
8:	D1<=2559;
9:	D1<=5119;
10:D1<=10239;
11:D1<=20479;
12:D1<=40959;
13:D1<=81919;
14:D1<=163839;

endcase
end
else 
D1<=D1-1;
end

endmodule

