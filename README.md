# GVIZI
author AbrametsTI
This is Master' thesis project
2023-2024 year
Name of the project "Генератор задержанных импульсов" or "Delay signal generator"

Данное устройство создано для внесения задержки в управляющие сигналы на научных ускорителях.
Главная задача устройства вносить программную задержку с разрешением не более 150 пс и среднеквадратичным джиттером не более 100 пс на время до 10 мкс.

Поскольку сам концепт немного устарел и впринципе разобраться в этом очень сложно, для начала поясню зачем это надо было и его принцип работы.

Допустим у нас есть один управляющий сигнал, от которого запускаются все системы ускорителя. 
Но проблема в том, что все эти системы: магниты, измерительное оборудование и т.д, могут быть на большом расстоянии. 
Но нам нужно запускать системы с такой точностью, чтобы мы могли поймать частицы.

Как можно задержать цифровой сигнал на десятки микросекунд, при этом внеся искажения в виде джиттера менее 150 пс, используя только частоту в 100 МГц?
Если использовать простые счетчики, то максимум который мы можем получить - это джиттер в 5 нс.

Решение заключается в следующем: мы отправляем фронт сигнала, который необходимо задержать, на интегрирование на конденсаторе. 
Это позволяет "сохранить" время появления сигнала относительно тактовой частоты. После этого можно запустить обычные счетчики, 
отсчитать необходимое время и "добавить" сохраненное время в виде заряда на конденсаторе. Этот конденсатор также подключен к быстродействующему компаратору, который срабатывает при совпадении уровней напряжения на его входах.
Дальше лишь дело техники. Посчитать и подобрать необходимые элементы.

Устройство состоит из цифрового блока (ПЛИС) и аналогового блока. 
Основная задача ПЛИС заключается в приеме управляющих пакетов по SPI-интерфейсу и мультиплексировании данных на АЦП и внутренние счетчики.
Аналоговый блок кроме хранения "времени" появления сигнала может также смещать нулевую точку с которой заряжается конденсатор. За счет этого к уже дискретной задержке, которая определяется тактовой частотой можно добавить аналоговую задержку
Если заряжать конденсатор постоянным током, то для расчетов можно использовать простую формулу I*t = C*U;
где I - ток с которым мы заряжаем конденсатор, t - время заряда конденсатора до уровня напряжения U, C - емкость конденсатора.

Поэтому можно подобрать номиналы так, что за 1 период clk конденсатор заряжался на нужное нам напряжение,
а за счет дополнительной схемы смещения и быстродействующего компаратора, можно регулировать время через которое сигнал сгенерируется. 
Поскольку задерживаемый сигнал появляется в случайной фазе относительно тактовой частоты, то допустим если U_T1 - напряжение за которое заряжается конденсатор за 1 период clk,
то при уровне заполнения (Duty cycle) 50% неопределенность будет 0.5-1.5T и соответственно 0.5*U_T1 - 1.5*U_T1. 
Не забываем что наш интегрирующий конденсатор также подключен к компаратору. Поэтому надо установить сравнивающее напряжение, немного больше, чем 1.5*U_T1.

Теперь вся схема работы:
1) До появления сигнала устанавливается смещение на аналоговой схеме и выставляются значения в счетчиках FPGA
2) Появляется сигнал
3) С фронта этого сигнала заряжается конденсатор до ближайшего фронта тактовой частоты
4) Заряд прекращается
5) Запускаются счетчики
6) Как только счетчики досчитали, заряд продолжается до срабатывания компаратора.
7) На выходе компаратора генерируется задержанный сигнал.
8) Повторять до скончания веков

В папке expirements лежат осциллограммы с экспериментами на разных задержках. В названии обычно указано что-то типо 0xBBBBxBB, первая часть 0xBBBB - это цифровая задержка в тактах 100 МГц, вторая часть xBB - аналоговая задержка в ед. АЦП.

Лицензия: Используйте где хотите, если кто-то сможет это использовать я пожму ему руку.

