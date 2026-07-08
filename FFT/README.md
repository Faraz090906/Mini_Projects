# 8-Point Radix-2 SDF DIF FFT Processor - Digital Signal Processing 
This repository contains the synthesizable, fully pipelined, fixed-point 8-point Radix-2 Single-Delay Feedback (SDF) Fast Fourier Transform (FFT) processor that I designed in Verilog. The implementation uses a Decimation-in-Frequency (DIF) algorithm layout to process streaming complex-valued data inputs sequentially.

## Author
* Patnam Shariq Faraz Muhammed (EE24BTECH11049)

---

## Objectives
The primary focus of my design was to:
* Implement a streaming Radix-2 8-point FFT in Verilog that accepts one complex sample per clock cycle, requiring 8 clock cycles to receive a full frame.
* Use a pipelined Single-path Delay Feedback (SDF) Decimation-in-Frequency (DIF) architecture with three butterfly stages.
* Verify the Verilog output against MATLAB's `fft()` reference across multiple test cases.
* Report synthesis results including resource utilization and timing using Quartus Prime 25.1 for an Intel Cyclone V FPGA.

---

## Architecture Overview

I implemented an SDF (Single-Delay Feedback) architecture to minimize hardware resource utilization on the FPGA. Rather than deploying complete parallel butterfly clusters, my design uses internal shift registers to buffer historical stream elements, processing intermediate data pairs sequentially through a single pipelined structural stage.

An 8-point Radix-2 FFT requires $\log_2(8) = 3$ computational stages. Data routes sequentially through:
1.  **Stage 1:** Buffers data with a feedback latency spacing of 4 clock cycles.
2.  **Stage 2:** Buffers data with a feedback latency spacing of 2 clock cycles.
3.  **Stage 3:** Buffers data with a feedback latency spacing of 1 clock cycle.

---

## Directory and Module Structure

The project code is organized into the following synthesizable modules:

* **`fft8_sdf_dif_top` / `fft`**: The top-level wrapper managing the 3-stage computational pipeline, parsing bit-growth configurations, and handling input sign-extensions.
* **`stage`**: The pipelined hardware core handling data scheduling. It includes memory blocks for local sample delays, logic to control multiplexing between feedback channels and current streams, and twiddle-factor selection based on the current step count.
* **`butterfly_dif`**: The Decimation-In-Frequency (DIF) butterfly structure. It computes concurrent vector arithmetic: `sum = A + B` and `diff_tw = (A - B) * W`.
* **`complex_mult`**: A fixed-point 4-multiplier complex mathematical unit. It computes cross-multiplications, performs bitwise adjustments (`>>> FRAC`), and truncates intermediate sizing to avoid data overflow errors.
* **`complex_add` / `complex_sub`**: Basic parallel arithmetic calculation blocks used across stages.

---

## Parameter Configurations

My design offers fully custom parameters for fixed-point quantization arithmetic configurations:

| Parameter | Default Value | Description |
| :--- | :--- | :--- |
| **`IN_INT`** | `3` | Number of integer bits allocated for signed inputs. |
| **`INT`** | `6` | Number of integer bits allocated for internal stages to manage bit growth. |
| **`FRAC`** | `5` | Number of fractional bits allocated for decimal accuracy. |
| **`IN_W`** | `IN_INT + FRAC` | Calculated total input word bit-width. |
| **`W`** | `INT + FRAC` | Calculated total internal/output word bit-width. |

---

## Port Interfaces

### Top-Level (`fft8_sdf_dif_top`)

| Signal Name | Direction | Description |
| :--- | :--- | :--- |
| **`clk`** | Input | Master System Clock. |
| **`rst`** | Input | Active-High Synchronous Reset. |
| **`valid_in`** | Input | Strobe declaring valid streaming input data. |
| **`xr_in`** / **`xi_in`** | Input | Signed Fixed-Point Complex Input (Real / Imaginary). |
| **`valid_out`** | Output | Asserted when output streams contain processed frequency coefficients. |
| **`xr_out`** / **`xi_out`**| Output | Signed Fixed-Point Complex Output (Real / Imaginary). |

---

## Synthesis Results

I synthesized the design using Quartus Prime 25.1 targeting an Intel Cyclone V FPGA. The custom streaming implementation achieved the following metrics:

* **Maximum Frequency ($F_{max}$):** 66.34 MHz
* **Worst-Case Slack:** +4.926 ns (comfortably meeting typical timing constraints)
* **DSP Blocks:** 6
* **Registers:** 250
* **Block RAM Bits:** 0 (utilizes internal registers/shift-registers for delay matching)

---

## Verification and Simulation

I verified the Verilog output against MATLAB behavioral benchmarks across four different complex data test cases using Icarus Verilog for simulation. 

* **Latency:** The design accepts one complex 8-bit sample per clock cycle and produces one FFT output per clock after an initial pipeline latency of 15 cycles.
* **Accuracy:** Functionally, my custom SDF FFT output matches the reference behavior within 1–2 LSB across all test cases, validating the precision of the fixed-point quantization parameters.

### Running Simulation via Icarus Verilog
To compile the structural source files and run the verification testbench setup, execute the following commands in your terminal:

```bash
# Compile Verilog source files
iverilog -o fft_sim complexArthmatic.v butterfly.v fft.v fft_tb.v

# Execute simulation to generate VCD traces
vvp fft_sim