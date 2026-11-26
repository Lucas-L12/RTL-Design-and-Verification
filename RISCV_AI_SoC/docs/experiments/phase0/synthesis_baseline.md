# Phase 0: synthesis baseline

First resource and timing figures for the SoC without the accelerator (PicoRV32, `bus_decoder`, 16 KB `ram`, `mmio_regs`). They are the reference against which the cost of the accelerator is measured in later phases.

## Setup

| Item | Value |
|---|---|
| Date | 2026-11-23 |
| Tool | Vivado, synthesis only (no implementation run) |
| Target device | `xc7a12ticsg325-1L` (Artix-7) |
| Top module | `top` |
| Firmware loaded in RAM | `sw/firmware.mem` (Phase 0 test program) |
| Clock constraint | 10.000 ns (100 MHz) on `clk`, see `constraints/top.xdc` |
| Pin assignment | none (ports left unassigned) |

## Resource utilization (post-synthesis)

| Resource | Used | Available | Utilization |
|---|---|---|---|
| Slice LUTs | 3282 | 8000 | 41% |
| Slice registers (flip-flops) | 664 | 16000 | 4% |
| F7 muxes | 1089 | 7300 | 15% |
| F8 muxes | 540 | 3650 | 15% |
| Bonded IOB | 36 | 150 | 24% |
| BUFGCTRL | 1 | 32 | 3% |
| Block RAM, DSP | 0 | | |

Breakdown by block (hierarchy report):

| Block | Slice LUTs | Slice registers | F7 muxes | F8 muxes |
|---|---|---|---|---|
| `u_cpu` (picorv32) | 1106 | 632 | 1 | 0 |
| `u_ram` (ram) | 2176 | 0 | 1088 | 540 |
| Total (`top`) | 3282 | 664 | 1089 | 540 |

`mmio_regs` and `bus_decoder` have no row of their own: their logic is small and is merged into the rows above. The 32 registers of the total that do not belong to the CPU are the DATA register of `mmio_regs`. The 36 I/O pins correspond to `clk`, `resetn`, `trap`, `bus_error` and the 32 bits of `data_out`.

## Timing (post-synthesis, 10 ns clock)

| Metric | Value |
|---|---|
| Worst negative slack (WNS, setup) | +3.038 ns |
| Total negative slack (TNS) | 0.000 ns |
| Worst hold slack (WHS) | +0.107 ns |
| Total hold slack (THS) | 0.000 ns |
| Failing endpoints | 0 of 22289 |

All user-specified timing constraints are met. With a 10 ns period and 3.038 ns of setup slack, the worst path is about 6.96 ns, which suggests a maximum frequency near 144 MHz. This is a synthesis estimate that does not include routing delays, so the real figure after implementation will be lower.

## Observations

- The RAM dominates the area: 2176 of the 3282 LUTs (66%). Because `ram.sv` has a combinational read, Vivado cannot use block RAM and builds the memory from LUTs used as distributed RAM (512 instances of `RAM256X1S`, which is exactly 4096 x 32 bits). Changing to a synchronous read (one wait state) would move the memory to BRAM and free about 2000 LUTs.
- The CPU is small: 1106 LUTs and 632 registers with the default configuration (RV32I, no multiplier, no compressed instructions, no interrupts).
- The accelerator was previously found to close timing at 80 MHz on its own, not at 100 MHz. The system clock for Phase 1 is therefore likely to be limited to 80 MHz or less, and the clock constraint should be revisited when the accelerator is attached.

## Limitations

- Post-synthesis figures only; no placement, routing or power data.
- Ports are not assigned to pins, so this design cannot yet be taken to a bitstream.
