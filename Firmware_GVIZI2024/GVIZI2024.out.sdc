## Generated SDC file "GVIZI2024.out.sdc"

## Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 14.1.0 Build 186 12/03/2014 SJ Web Edition"

## DATE    "Mon May 13 15:41:19 2024"

##
## DEVICE  "EPM570T100C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 2



#**************************************************************
# Create Clock
#**************************************************************


create_clock -name {i_clk_internal} -period 10.00 -waveform { 0.00 5.00 } [get_ports { i_clk_internal }]
create_clock -name {i_start} -period 10000.00 -waveform { 0.00 5000.00 } [get_ports { i_start }]



#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************




#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_clocks {i_start}] -to [get_ports {o_Ch_discharge[0] o_Ch_discharge[1] o_Ch_discharge[2] o_Ch_discharge[3]}] 7.50


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from [get_clocks {i_start}] -to [get_ports {o_Ch_charge[0] o_Ch_charge[1] o_Ch_charge[2] o_Ch_charge[3]}] 17.00


#**************************************************************
# Set Input Transition
#**************************************************************

