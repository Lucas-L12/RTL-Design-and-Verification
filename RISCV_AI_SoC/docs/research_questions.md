# Research Questions

**RQ1**: What speedup does hardware execution of the convolution provide compared to a software implementation running on the RISC-V processor?

**RQ2**: How does data transfer between memory and the accelerator affect overall end-to-end performance?

**RQ3**: What benefit does a DMA mechanism provide over direct processor-controlled access?

**RQ4**: What is the trade-off between accelerator parallelism (number of simultaneous MACs) and FPGA resource utilization (LUTs, FFs, BRAM, DSP)?

Each RQ has an associated experiment; results and data live under `docs/experiments/`, one subfolder per phase.

## Open questions before committing further

- RQ4 assumes the existing conv2D accelerator's MAC count is a sweepable parameter. Not yet verified against the actual RTL from the summer project — confirm before Phase 4 planning.
- Polling vs. interrupt-driven completion signaling for the accelerator is an explicit open decision for Phase 1, not yet made. Starting with polling (STATUS register) for simplicity; revisit if Phase 2 data shows significant CPU time lost to polling.
