# RISC-V + Convolution Accelerator SoC

A small SoC built around the PicoRV32 core, designed to study how a 2D convolution accelerator should be attached to a RISC-V processor and what the data transfer between memory and accelerator costs. The processor core is vendored (see `rtl/core/PROVENANCE.md`); the memory, the bus decoder, the memory-mapped peripheral, the accelerator wrapper, the top level, the firmware and all testbenches in this folder are written for this project. The convolution engine itself comes from an earlier standalone accelerator project (`../2D_Convolutional_Accelerator`) and was adapted to the bus.

## Status

Phase 0 (processor, RAM, address decoder, test peripheral) and Phase 1 (accelerator attached to the bus, driven by C code running on the CPU) are complete and verified in simulation. The design has not been run on a physical board.

| Item | Result |
|---|---|
| `tb_ram` | 18/18 checks pass |
| `tb_mmio_regs` | 18/18 checks pass |
| `tb_bus_decoder` | 17/17 checks pass (RAM, peripheral, accelerator, unmapped zones) |
| `tb_wrapper` | 22/22 checks pass (status flags, illegal accesses, 169 output words against the expected result, two consecutive runs) |
| `tb_top`, Phase 0 firmware (`tests/main.c`) | PASS in 253 cycles |
| `tb_top`, Phase 1 firmware (`tests/main_conv.c`) | PASS in 43346 cycles, `trap`, `bus_error` and accelerator `ERROR` never asserted |
| Negative test (wrong expected ID in the Phase 0 firmware) | `tb_top` reports FAIL with `data_out = 0xBAD1`, as expected |

## Why this project

Existing RISC-V accelerator work at the university level tends to extend the core itself (custom instructions, vector or matrix units). This project instead attaches an accelerator as a memory-mapped device and measures the cost of moving data to and from it, which is the part those works do not study. It builds on an earlier standalone 2D convolution accelerator and its UVM verification environment, and on a from-scratch single-cycle RV32I core (`../RISCV_Core`).

## Research Questions

See [docs/research_questions.md](docs/research_questions.md).

## Architecture

The PicoRV32 core talks to the rest of the system through its native memory interface: `mem_valid`, `mem_addr`, `mem_wdata`, `mem_wstrb`, `mem_rdata` and `mem_ready`. A request is a `mem_valid` pulse with the address (and data and byte strobes for writes); the target answers with `mem_ready` (and `mem_rdata` for reads). RAM, the test peripheral and the accelerator status and input registers answer in the same cycle; reading the accelerator output takes one wait state.

```
              +----------------------------- top ------------------------------+
 clk -------->|                                                                |
 resetn ----->|  PicoRV32 --> bus_decoder --ram_valid--> ram                    |--> trap
              |   (CPU)            |   <--ram_rdata/ram_ready--                |--> bus_error
              |                    +--per_valid--> mmio_regs                   |--> data_out
              |                    |   <--per_rdata/per_ready--                |
              |                    +--acc_valid--> Wrapper --> conv_accel      |
              |                        <--acc_rdata/acc_ready--                |
              +----------------------------------------------------------------+
```

`mem_addr`, `mem_wdata` and `mem_wstrb` go to every device. `mem_valid` goes through the decoder, which forwards it only to the selected device, and the decoder also selects which `rdata` and `ready` return to the core.

| Block | File | Role |
|---|---|---|
| CPU | `rtl/core/picorv32.v` | PicoRV32, RV32I, `PROGADDR_RESET = 0`, `STACKADDR = 0x4000` |
| `bus_decoder` | `rtl/bus/bus_decoder.sv` | Selects the device from `mem_addr[31:28]`, muxes `rdata` and `ready`, flags unmapped accesses |
| `ram` | `rtl/memory/ram.sv` | 4096 x 32-bit (16 KB), combinational read, synchronous write with per-byte strobes, preloaded from `firmware.mem` |
| `mmio_regs` | `rtl/bus/mmio_regs.sv` | Test peripheral with two registers |
| `Wrapper` | `rtl/bus/Wrapper.sv` | Bus-side interface of the accelerator: register decoding, BUSY/DONE/ERROR flags, wait state on output reads |
| `conv_accel` | `rtl/accelerator/conv_accel.sv` | Accelerator top: controller, convolution engine, requantizer and the two memories |
| `Memory_In`, `Memory_out` | `rtl/accelerator/` | 28x28 int8 input and 26x26 int8 output, stored as 32-bit words and accessible by byte |
| `top` | `rtl/top.sv` | Instantiates and wires the blocks above |

The accelerator computes a 3x3 convolution with a fixed Sobel kernel on a 28x28 int8 image, producing a 26x26 int8 result after requantization.

### Address map

| Region | Base address | Selected by `mem_addr[31:28]` |
|---|---|---|
| RAM | `0x00000000` | `0x0` |
| Test peripheral | `0x10000000` | `0x1` |
| Convolution accelerator | `0x20000000` | `0x2` |
| Unmapped | everything else | any other value |

An access to an unmapped address returns `0xDEADDEAD`, still completes (so the CPU does not hang) and raises `bus_error` while the access lasts.

### Test peripheral registers (`mmio_regs`)

| Offset | Name | Access | Description |
|---|---|---|---|
| `0x00` | DATA | read/write | 32-bit register, reset value 0, byte-wise writes through `wstrb`. Its value is exposed on `data_out` |
| `0x04` | ID | read-only | Constant `0xC0FFEE01` |
| `0x08`, `0x0C` | none | | Read as 0, writes ignored |

### Accelerator registers and memories

Inside the accelerator window, `addr[11:10]` selects the region.

| Address | Name | Access | Description |
|---|---|---|---|
| `0x20000000` | START | write | Any write while idle starts a run. Clears DONE and ERROR, sets BUSY. Reads as 0 |
| `0x20000004` | STATUS | read | `{29'b0, ERROR, BUSY, DONE}`. Writes are ignored |
| `0x20000400` - `0x2000071C` | INPUT | write | 196 words, the 28x28 input image (byte 0 in bits `[7:0]`). Reads as 0 |
| `0x20000800` - `0x20000AA0` | OUTPUT | read | 169 words, the 26x26 result. Indices 169 to 255 read as 0. Writes are ignored |
| `0x20000C00` and above | none | | Read as 0, writes ignored |

Behaviour:

- DONE is sticky: it stays set until the next START.
- While BUSY, writes to START and INPUT are ignored and set ERROR. Reading OUTPUT while BUSY also sets ERROR.
- ERROR is cleared by the next accepted START.
- STATUS and INPUT accesses take one cycle; an OUTPUT read takes two (the memory has a synchronous read).

### Firmware

`sw/tests/main.c` (Phase 0) checks, from the CPU side, each path through the system: it reads ID, writes and reads back DATA with a 32-bit access, writes a single byte of DATA (which makes the core emit `sb` and a partial `wstrb`), reads a global variable with a non-zero initial value (checks that `.data` was loaded) and calls a function that uses the stack.

`sw/tests/main_conv.c` (Phase 1) is the accelerator driver. It copies the 196 input words to the accelerator, writes START, polls STATUS until DONE, checks that ERROR is clear, and compares the 169 output words with the expected result. The image and expected output are C arrays (`imagen.h`, `esperado.h`) generated from `sim/data/image.mem` and `sim/data/expected_output.mem` by `sw/tools/mem2h.py`, so they travel inside `firmware.mem` and need no hardware loader.

Both programs finish by writing `0x0000600D` to DATA on success or `0x0000BAD0 + errors` on failure, then loop forever. `sw/common/start.S` calls `main` and halts; `sw/common/link.ld` places everything in a single 16 KB RAM starting at address 0.

## Roadmap

1. Phase 0 (done): CPU, RAM, decoder and test peripheral running C code in simulation.
2. Phase 1 (done in simulation): accelerator attached as a third device (`0x2...`); the CPU copies the input data through the bus and reads the result. Remaining: cycle breakdown (copy, compute, readback) and synthesis delta against the Phase 0 baseline.
3. Later phases: software baseline, DMA, and the parallelism versus resources study (see the research questions).

## Experimental results

- Phase 0 synthesis baseline: [docs/experiments/phase0/synthesis_baseline.md](docs/experiments/phase0/synthesis_baseline.md).
- Phase 1 total run time with the CPU copying the data over the bus: 43346 cycles for copy, compute, polling and readback together (firmware built without optimization flags). A per-phase breakdown and the synthesis comparison are pending.

## Repository structure

```
rtl/
  top.sv
  core/         picorv32.v (vendored, see PROVENANCE.md), COPYING.picorv32
  bus/          bus_decoder.sv, mmio_regs.sv, Wrapper.sv
  memory/       ram.sv
  accelerator/  conv_accel.sv, controller.sv, conv_engine.sv, Mac_Unit.sv,
                requantizer.sv, Memory_In.sv, Memory_out.sv
sim/            tb_ram.sv, tb_mmio_regs.sv, tb_bus_decoder.sv, tb_wrapper.sv, tb_top.sv
  data/         image.mem, expected_output.mem
sw/
  common/       start.S, link.ld
  tests/        main.c (Phase 0), main_conv.c (Phase 1), imagen.h, esperado.h
  tools/        mem2h.py
  firmware.mem  Firmware image used by the simulation (generated, kept as reference)
scripts/        create_vivado_project.tcl
docs/           research_questions.md, experiments/
constraints/    top.xdc
```

## Reproducing the results (Vivado)

1. Build the firmware on a machine with the RISC-V toolchain (`riscv64-unknown-elf-gcc`), from `sw/`. Use `tests/main.c` for the Phase 0 test or `tests/main_conv.c` for the accelerator test:

   ```
   riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -T common/link.ld common/start.S tests/main_conv.c -o firmware.elf
   riscv64-unknown-elf-objcopy -O binary firmware.elf firmware.bin
   od -An -v -tx4 -w4 firmware.bin > firmware.mem
   ```

   Optionally check the layout with `riscv64-unknown-elf-objdump -d firmware.elf`: `_start` must be at address `0x00000000`. To regenerate the data headers, run `python ../../sw/tools/mem2h.py` from `sim/data` and move `imagen.h` and `esperado.h` to `sw/tests/`.

2. Create the Vivado project with `scripts/create_vivado_project.tcl` (Tools > Run Tcl Script, with no project open). It references the files in the repository without copying them, sets `top` as the design top and `tb_wrapper` as the simulation top.
3. To rerun a testbench, set it as the simulation top (`tb_top`, `tb_wrapper`, `tb_bus_decoder`, `tb_mmio_regs` or `tb_ram`) and relaunch the simulation (not only `run all`, so that `firmware.mem` is read again). Each prints `PASS` or a list of failures.

## Known limitations / future work

- The RAM uses a combinational read, which Vivado infers as distributed (LUT) memory. A synchronous read (with one wait state) is needed to use block RAM and will be revisited once synthesis results are collected.
- The firmware image is loaded with `$readmemh` in simulation; the same file must be included as a design source for synthesis.
- The accelerator kernel is fixed (Sobel) and there is a single convolution layer; there are no activation or pooling stages.
- The accelerator closed timing at 80 MHz as a standalone block; the SoC constraint file uses a 10 ns clock and the combined design has not been checked against it yet.
- The firmware is RV32I only (no multiplier or divider), so it must avoid `*`, `/` and `%` unless `libgcc` is linked.
- DMA and interrupt-driven completion are not implemented.
- Everything was verified in simulation only; nothing has been run on a physical board.