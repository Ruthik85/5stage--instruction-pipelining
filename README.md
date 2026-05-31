# 5stage--instruction-pipelining
A classic 5-stage pipelined RISC-V processor implemented in Verilog and verified via ModelSim. Features distinct Fetch, Decode, Execute, Memory, and Writeback stages. Addresses data and control hazards using forwarding/stalling, validated through comprehensive waveform analysis.
## 🚀 Project Overview

This repository contains a structural Verilog implementation of a **5-stage pipelined RISC-V (RV32I) processor core**. By breaking down instruction processing into five distinct operational stages, the architecture optimizes data path efficiency, balances propagation delays, and maximizes instruction-level parallelism (ILP).

### Architectural Structure
1. **Instruction Fetch (IF):** Fetches instructions from memory and increments the PC.
2. **Instruction Decode (ID):** Extracts opcodes, sign-extends immediate fields, and fetches register operands.
3. **Execute (EX):** Computes results using a multi-functional Arithmetic Logic Unit (ALU).
4. **Memory Access (MEM):** Reads from or writes to data memory for load/store operations.
5. **Writeback (WB):** Commits results back to the architectural register file.

---

## ⚙️ Implementation Process

### 1. Inter-Stage Pipeline Registers
Four structural register layers were implemented to isolate data and control boundaries:
* **IF/ID:** Holds the fetched instruction and its corresponding PC.
* **ID/EX:** Saves register operands and routes execution control signals (ALUOp, ALUSrc).
* **EX/MEM:** Stores calculated memory addresses, data to be written, and memory control flags (MemRead, MemWrite).
* **MEM/WB:** Carries loaded memory data or ALU outputs alongside the writeback control token (RegWrite).

### 2. Hazard Resolution Unit
A 5-stage pipeline introduces structural, data, and control hazards that must be managed to prevent data corruption:
* **Data Forwarding (Bypassing):** Routes data directly from the EX/MEM or MEM/WB registers back to the ALU inputs, resolving **Read-After-Write (RAW)** dependencies without stalling the processor.
* **Hazard Detection & Stalling:** Introduces a pipeline stall (bubble) when a load instruction (`LW`) is immediately followed by a dependent instruction.
* **Control Hazard Mitigation:** Flushes invalid instructions from the pipeline stages (converting them to `NOP`s) when a branch or jump condition is evaluated as taken.

---

## 👨‍💻 How to Run and Simulate the Processor

### 1. Compile the Environment
* Launch **ModelSim** and establish a new project workspace.
* Import all source modules (including `if_id.v`, `id_ex.v`, `ex_mem.v`, `mem_wb.v`, alongside core computational blocks) and the structural testbench (`riscv_tb.v`).
* Execute **Compile All** and ensure zero syntax anomalies exist.

### 2. Load and Run Simulation
* Navigate to the **Library** tab, locate the compiled `work` space, right-click `riscv_tb`, and select **Simulate**.
* Add the following essential diagnostic signals to the **Wave window** to track the 5-stage flow:
  * `clk` / `rst`
  * `PC`
  * `IF_ID_instruction` (Current Fetch/Decode boundary)
  * `ID_EX_alu_out` (Current Execution boundary)
  * `EX_MEM_mem_addr` (Current Memory stage focus)
  * `MEM_WB_reg_write_data` (Final Writeback target)
* Set the run window to `200ns` and trigger the execution (`run`). 

### 3. Verifying Pipeling in Waveforms
Observe how a single instruction progresses sequentially across five consecutive clock cycles, while up to five distinct instructions occupy the stages simultaneously. Confirm that data dependencies are successfully resolved by checking if the forwarding multiplexers update the ALU inputs with the correct bypassed values before an operation occurs.
