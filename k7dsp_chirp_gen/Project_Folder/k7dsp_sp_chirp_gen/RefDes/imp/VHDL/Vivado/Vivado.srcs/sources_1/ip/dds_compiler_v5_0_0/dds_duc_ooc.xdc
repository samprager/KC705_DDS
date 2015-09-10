# This constraints file contains default clock frequencies to be used during out-of-context flows such as
# OOC Synthesis and Hierarchical Designs. For best results the frequencies should be modified
# to match the target frequencies.
# This constraints file is not used in normal top-down synthesis.

# Using clock frequency specified in IP parameterization: 245.7600000000000000 MHz
create_clock -name aclk -period 4.069 [get_ports aclk]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports aclk]
