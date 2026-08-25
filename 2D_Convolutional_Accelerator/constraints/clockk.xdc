## Clock constraint for the 2D Convolution Accelerator (Basys 3 / xc7a35tcpg236-1)
##
## The design's real critical path (MAC accumulate -> ACCR sum -> requantizer ->
## output memory write) does not close timing at the board's native 100 MHz.
## The clock was relaxed to 80 MHz (WNS = +0.357 ns, all constraints met) as
## documented in the README's "Timing Closure" section. An alternative not
## implemented here would be to add a pipeline register between ACCR and the
## requantizer to keep 100 MHz.

create_clock -period 12.500 -name clk -waveform {0.000 6.250} [get_ports clk]
