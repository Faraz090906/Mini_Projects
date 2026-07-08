# 100-Tap Pipelined FIR Low-Pass Filter Architectures

This repository contains the synthesizable, parameterized Verilog implementations, simulation testbenches, and technical analysis for a 100-tap Finite Impulse Response (FIR) low-pass filter across three distinct hardware architectures. All designs process fixed-point inputs using a Q2.14 numeric format and feature overflow saturation protection.

## Author
* Patnam Shariq Faraz Muhammed (EE24BTECH11049)
---

## Objectives
The primary design goals of this project are:
* Implement a 100-tap low-pass FIR filter in Verilog using three distinct structural architectures: Direct Form (Serial), Optimized Symmetric, and Genvar-Based Fully Parallel.
* Implement pipelined versions for each architecture to isolate combinational delays along the critical path and maximize maximum operational frequency ($F_{max}$).
* Validate the numerical accuracy of fixed-point RTL outputs against floating-point MATLAB references.
* Compare hardware resource utilization (DSP blocks, Registers, Logic Element counts) and timing closures on an Intel Cyclone V FPGA using Quartus Prime 25.1.

---

## Filter Specifications & Sizing Parameters

All architectures leverage parameterized word widths to adapt bit growth along the internal computation pipelines:

| Sizing Parameter | Default Value | Description |
| :--- | :--- | :--- |
| **`a`** | `2` | Number of integer bits allocated for signed input. |
| **`b`** | `14` | Number of fractional bits allocated for high-precision representation (Q2.14). |
| **`W`** | `a + b + 1 = 17` | Total structural signal word width including sign bit. |
| **`CW`** | `16` | Width allocated for the fixed-point filter coefficients. |
| **`PROD_W`** | `W + CW = 33` | Intermediate product word width following multiplication. |
| **`ACC_W`** | `42` | Expanded wide accumulator bit-width to manage bit growth without truncation errors. |

### Saturation Logic
To eliminate wrap-around arithmetic distortions during multi-stage additions, the final filtering output passes through a structural saturation function (`sat_shift`). If the shifted accumulation value exceeds the upper or lower boundaries allowed by the 17-bit output window, it clips the value cleanly to `max_val` (`0x03FFF`) or `min_val` (`0x1C000`).

---

## Supported Architectures

### 1. Direct Form (Serial Iterative MAC) — `direct.v`
* **Mechanism:** Employs a single shared hardware multiplier-accumulator (MAC) array unit to calculate responses iteratively. 
* **Behavior:** Incoming samples are buffered in a 100-stage register shift delay-line. For every single input sample, an internal state counter loops through all 100 coefficients sequentially, shifting intermediate products into a wide register.
* **Trade-off:** Ultra-low resource footprint (only 1 multiplier block needed), but high latency and significantly lower data throughput.

### 2. Optimized Symmetric FIR — `optimized.v`
* **Mechanism:** Explodes the linear-phase symmetry property inherent to standard low-pass filtering functions where:
  $$h[n] = h[N - 1 - n]$$
* **Behavior:** Pre-adds the symmetric historical data samples pairs ($x[n] + x[N-1-n]$) before routing them into the multiplication block. 
* **Trade-off:** Reduces the structural multiplier requirement by exactly half ($100 / 2 = 50$), optimizing DSP efficiency while maintaining serial-to-parallel scaling boundaries.

### 3. Genvar-Based Fully Parallel Pipelined FIR — `genvar_fir.v`
* **Mechanism:** Implements a highly parallelized, systolic-like processing array built out of cascading `fir_cell` modules generated via structural loops.
* **Behavior:** Every cell integrates a local coefficient multiplier, an addition chain node, and inter-stage pipelining registers (`a_delay`, `bo`, `en_out`). 
* **Trade-off:** Achieves maximum conceivable data throughput (delivering 1 valid filtered sample output *every single clock cycle* after filling the initial pipeline) at the expense of an expanded FPGA logic-element footprint.

---

## Performance and Timing Summary (Cyclone V FPGA)

The architectures were synthesized using **Quartus Prime 25.1** targeting an Intel Cyclone V hardware framework. The performance, timing slack boundaries, and operational throughput scale as follows:

| Architecture Configuration | Max Frequency ($F_{max}$) | Worst-Case Slack | Effective Data Throughput |
| :--- | :--- | :--- | :--- |
| **Direct Form (Non-Pipelined)** | 28.36 MHz | -15.975 ns | 0.284 MHz |
| **Optimized Symmetric (Non-Pipelined)** | 29.03 MHz | -15.407 ns | 0.581 MHz |
| **Genvar Parallel (Non-Pipelined)** | 49.19 MHz | +6.008 ns | 49.19 MHz |
| **Direct Form (Pipelined)** | 59.52 MHz | +3.409 ns | 0.595 MHz |
| **Optimized Symmetric (Pipelined)** | 70.64 MHz | +6.008 ns | 1.413 MHz |
| **Genvar Parallel (Pipelined)** | *Exceeds Baseline* | *Positive Closure* | *High Frequency Sync* |

*Note: Pipelining successfully splits the multiplier-accumulator propagation paths, converting negative setups into safe positive slacks, effectively doubling the filter's operational ceiling.*

---

## Verification & Simulation

System behaviors can be compiled and validated using **ModelSim** or **Icarus Verilog** alongside reference wave viewers like GTKWave.

### Running Verification via ModelSim / CLI
To compile the structural source assets and invoke test verification loops, run:

```bash
# Compile the chosen hardware architectural component
vlog direct.v optimized.v genvar_fir.v

# Simulate test sequences to confirm mathematical parity with MATLAB reference arrays
vsim -c -do "run -all; quit" tb_fir_module