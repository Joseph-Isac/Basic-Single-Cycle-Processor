## Overview
This project implements a basic 32-bit MIPS single-cycle processor to understand the fundamental working of a CPU — specifically how it fetches, decodes, and executes instructions. It is developed using **Verilog HDL** and simulated using **Intel Quartus Prime Lite Edition** with **ModelSim-Altera** on the **MAX 10: 10M50DAF484C7G** FPGA.

## Objective
The goal of this project is to build a minimalistic MIPS processor that supports the execution of a subset of MIPS instructions using single-cycle datapath and control logic. It serves as a hands-on exercise in understanding processor internals, instruction formats (R, I, J types), and memory/register file interaction.

## Development Tools
- **Intel Quartus Prime Lite Edition**
- **ModelSim-Altera for simulation**
- **FPGA Target:** MAX 10 (10M50DAF484C7G)
- **HDL:** Verilog

## Reference
The processor was developed based on the detailed roadmap provided by the institute:  
🔗 [https://hwlabnitc.github.io/Verilog/SingleCycle.html](https://hwlabnitc.github.io/Verilog/SingleCycle.html)

## Key Features
- Implements **R-type**, **I-type**, and **J-type** instructions.
- Fully commented instruction memory for switching between different test cases.
- Uses a **single-cycle** datapath to execute instructions in one clock cycle.
- Includes all core components:
  - Instruction Memory (`imem`)
  - Data Memory (`dmem`)
  - Register File (`regfile`)
  - ALU and ALU Control
  - Control Unit (`CU`)
  - Datapath
  - Top-Level `Processor` module

## Instruction Input
- Instructions are entered manually in **32-bit binary** format inside the `imem` module.
- Only **64 instructions** can be stored due to the limited memory size (`RAM[63:0]`).
- Instruction types:
  - **R-Type** (e.g., `add`, `sub`, `and`, `or`, `slt`)
  - **I-Type** (e.g., `lw`, `sw`, `beq`, `addi`)
  - **J-Type** (e.g., `j`)

## Testing
- A rudimentary **testbench** is used to validate processor behavior on various instruction combinations.
- The `imem` module contains **commented blocks** to test individual instruction types. Uncomment any block to test a specific instruction sequence.

## Known Limitation
- The **data memory** (`dmem`) is implemented as an array of 64 entries (each 32 bits).
- The memory address calculation uses `dataaddr[31:2]`, i.e., word-aligned addressing.
- However, **16-bit offsets** in instructions like `lw`/`sw` can lead to non-word-aligned addresses.
  - **⚠️ Undefined Behavior**: If a non-word-aligned address is accessed, it may lead to unexpected results.
  - This design choice was intentional to preserve the simplicity of the datapath and control logic as per the original educational intent.

## Usage
1. Open the project in **Intel Quartus Prime Lite Edition**.
2. Choose **MAX 10 (10M50DAF484C7G)** as the target device.
3. Open `Processor.v` (top-level module).
4. Run simulation using **ModelSim-Altera**.
5. Modify instructions in `imem.v` to test different behaviors.

## Suggested Improvements
- Add hazard detection and forwarding units for multi-cycle or pipelined versions.
- Extend memory size and support for more MIPS instructions.
- Improve memory alignment checking to prevent undefined access behavior.

## License
This project is developed for educational purposes under academic guidance. Please refer to the linked roadmap for further details and reference code.

**AI Generated
