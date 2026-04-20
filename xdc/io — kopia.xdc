set_property PACKAGE_PIN Y9 [get_ports {clk}];

set_property PACKAGE_PIN R16 [get_ports {L0}];  # "BTND"
set_property PACKAGE_PIN N15 [get_ports {L4}];  # "BTNL"
set_property PACKAGE_PIN R18 [get_ports {L8}];  # "BTNR"
set_property PACKAGE_PIN T18 [get_ports {L16}];  # "BTNU"

set_property PACKAGE_PIN Y11 [get_ports {cs_dac}]; # "JA1"
set_property PACKAGE_PIN AA11 [get_ports {din}]; # "JA2"
#set_property PACKAGE_PIN Y10 [get_ports {JA3}]; # "JA3"
set_property PACKAGE_PIN AA9 [get_ports {sclk_dac}]; # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {JA7}]; # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {JA8}]; # "JA8"
#set_property PACKAGE_PIN AB9 [get_ports {JA9}]; # "JA9"
#set_property PACKAGE_PIN AA8 [get_ports {JA10}]; # "JA10"

#set_property PACKAGE_PIN W12 [get_ports {JB1}]; # "JB1"
#set_property PACKAGE_PIN W11 [get_ports {JB2}]; # "JB2"
#set_property PACKAGE_PIN V10 [get_ports {JB3}]; # "JB3"
#set_property PACKAGE_PIN W8 [get_ports {JB4}]; # "JB4"
set_property PACKAGE_PIN V12 [get_ports {cs_adc}]; # "JB7"
set_property PACKAGE_PIN W10 [get_ports {in_data}]; # "JB8"
#set_property PACKAGE_PIN V9 [get_ports {JB9}]; # "JB9"
set_property PACKAGE_PIN V8 [get_ports {sclk_adc}]; # "JB10"

set_property PACKAGE_PIN AB6 [get_ports {freq_sample}];  # "JC1_N"

#set_property PACKAGE_PIN U14 [get_ports {led[7]}];
#set_property PACKAGE_PIN U19 [get_ports {led[6]}];
#set_property PACKAGE_PIN W22 [get_ports {led[5]}];
#set_property PACKAGE_PIN V22 [get_ports {led[4]}];
#set_property PACKAGE_PIN U21 [get_ports {led[3]}];
#set_property PACKAGE_PIN U22 [get_ports {led[2]}];
#set_property PACKAGE_PIN T21 [get_ports {led[1]}];
#set_property PACKAGE_PIN T22 [get_ports {led[0]}];

#set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];