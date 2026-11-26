# Verilog / SystemVerilog Projects

A collection of digital design projects implemented in Verilog/SystemVerilog, focused on learning and applying hardware design concepts such as:

- Finite State Machines (FSM) and FSMD architectures
- UART communication protocols
- Processor microarchitecture (RISC-V)
- Hardware accelerators for neural-network inference
- Verification: directed testbenches and UVM
- Modular RTL design and FPGA synthesis/timing analysis

## Overview

| Project | What it is | Main result |
|---|---|---|
| [`fibonacci_fsmd`](fibonacci_fsmd) | Fibonacci calculator, FSMD architecture | Verified in simulation |
| [`UART`](UART) | UART transmitter, receiver and baud-rate generator | Loopback testbench |
| [`UART_Memory_System`](UART_Memory_System) | UART-controlled RAM with MPU protection | Self-checking, randomized and directed tests |
| [`2D_Convolutional_Accelerator`](2D_Convolutional_Accelerator) | INT8 2D convolution accelerator (Sobel on a 28x28 MNIST digit) | 676/676 bit-exact vs. Python model; closes timing at 80 MHz on Artix-7 |
| [`UVM_Conv_Accelerator`](UVM_Conv_Accelerator) | UVM verification environment for the accelerator | 14196/14196 PASS, 77.78% functional coverage |
| [`RISCV_Core`](RISCV_Core) | From-scratch single-cycle RV32I core | 11 modules verified; integration program passes |
| [`RISCV_AI_SoC`](RISCV_AI_SoC) | PicoRV32-based SoC with the convolution accelerator attached to the bus | C driver running on the CPU, PASS in 43346 cycles (simulation) |

Everything was verified in simulation with Vivado. No project has been deployed on a physical board yet.

## Projects

### Fibonacci FSMD

Implementation of a Fibonacci calculator using a Finite State Machine with Datapath (FSMD) architecture.

- FSM with three states: `idle`, `op`, `done`
- Iterative Fibonacci computation
- Clear separation between control path and datapath
- RTL simulation and verification

Key concepts: FSMD design methodology, sequential arithmetic operations, register-transfer level (RTL) design.

Folder: [`fibonacci_fsmd`](fibonacci_fsmd)

### UART (Universal Asynchronous Receiver Transmitter)

Full UART implementation in Verilog using a modular FSMD-based architecture.

- Configurable baud rate generator
- UART transmitter and receiver modules
- 16x oversampling receiver
- TX/RX synchronization logic
- Loopback verification testbench

Key concepts: serial communication, parallel-to-serial and serial-to-parallel conversion, tick-based synchronization, pulse generation and edge detection.

Folder: [`UART`](UART)

### UART Memory System with MPU Protection

UART-controlled memory system built around a centralized FSMD controller. An external device runs READ and WRITE transactions over UART, and an MPU (Memory Protection Unit) validates every access before it reaches the RAM.

- UART core, controller FSM, RAM and MPU as separate modules
- WRITE: `[WRITE_CMD] [ADDRESS] [DATA]`; READ: `[READ_CMD] [ADDRESS]`, answered with the stored value
- Error handling for invalid commands and invalid accesses
- Self-checking environment with randomized and directed tests

Folder: [`UART_Memory_System`](UART_Memory_System)

### 2D Convolution Accelerator

A from-scratch hardware accelerator for CNN inference, designed with the ASMD methodology. It performs INT8-quantized 3x3 convolution (Sobel kernel) on a real 28x28 MNIST digit: input quantization, a MAC-based convolution engine, INT8 requantization with round-half-to-even, and a 26x26 result in on-chip memory.

- Verified bit-exact against a Python/NumPy golden model (676/676)
- Unit, integration and full-system testbenches
- Synthesis and implementation on Artix-7: 662 LUTs, 264 FFs; the 100 MHz target failed timing and the design closes at 80 MHz

Folder: [`2D_Convolutional_Accelerator`](2D_Convolutional_Accelerator)

### UVM Verification Environment

A UVM testbench for the accelerator above, without modifying its RTL: constrained-random stimulus, a scoreboard with its own SystemVerilog reference model, and functional coverage.

- 20 random images plus one directed edge case: 14196/14196 PASS
- Functional coverage 77.78%, with the remaining gap documented
- Found and fixed a driver/monitor race that only appeared with back-to-back transactions
- Backdoor loading through `bind` as a workaround for Vivado XSim's disabled UVM DPI routines

Folder: [`UVM_Conv_Accelerator`](UVM_Conv_Accelerator)

### Single-Cycle RV32I RISC-V Core

A from-scratch single-cycle implementation of the RV32I base instruction set: register file, ALU, immediate generator, control unit, branch comparator, PC logic, memories and top-level datapath, designed from a hand-built datapath diagram.

- All RV32I instructions except byte/half-word loads and stores and the system instructions
- Directed testbenches for the main modules and an integration program (`addi`, `add`, `sw`, `lw`, `beq`)
- Documented limitations and next steps

Folder: [`RISCV_Core`](RISCV_Core)

### RISC-V SoC with Convolution Accelerator

A small SoC around the third-party PicoRV32 core with RAM, an address decoder, a test peripheral and the convolution accelerator attached as a memory-mapped device. A C program running on the CPU copies the image to the accelerator over the bus, starts it, waits for completion and checks the 169 output words against the expected result. The goal is to measure what moving data between memory and accelerator costs, as a base for studying DMA and parallelism.

- Wrapper with a register map (START, STATUS with DONE/BUSY/ERROR), illegal-access protection and a wait state for synchronous memories
- Testbenches: 18, 17 and 22 self-checking checks for the peripheral, decoder and wrapper, plus a system test
- System test passes in 43346 cycles, with the CPU copying the data

Folder: [`RISCV_AI_SoC`](RISCV_AI_SoC)

## How the projects relate

The accelerator was designed first (`2D_Convolutional_Accelerator`) and then re-verified with a UVM environment (`UVM_Conv_Accelerator`). After that, `RISCV_Core` moved from verification back to RTL design to learn processor microarchitecture. `RISCV_AI_SoC` brings these threads together: the accelerator adapted to a bus and driven by software on a RISC-V CPU.

## Tools

Vivado (XSim) for simulation, synthesis and implementation; SystemVerilog and Verilog for RTL; UVM 1.2 for the verification environment; Python/NumPy for golden models; GCC for RISC-V (`riscv64-unknown-elf-gcc`) for firmware.
