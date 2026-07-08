# Microphone Amplifier 

This contains the documentation, design schematics, and experimental results for my final project completed at the Indian Institute of Technology Hyderabad (IITH).

## Author
*  Patnam Shariq Faraz Muhammed (EE24BTECH11049)

---

## Objective
The primary objective of my project was to design, implement, and evaluate an audio amplification system consisting of a low-level voltage pre-amplifier stage followed by a Class-AB power amplifier. I designed the system to effectively amplify low-level audio signals from an auxiliary input to a level sufficient to drive a small 16 Ohm loudspeaker while maintaining low distortion, stable biasing, and high efficiency.

---

## System Architecture

The amplifier system I built consists of two cascaded stages to ensure proper gain distribution and load isolation:

### 1. Dual-Stage Common-Emitter Pre-Amplifier
*   **Transistors:** Two BC547B NPN transistors (Q1 and Q2).
*   **Function:** Provides high voltage amplification to bring weak microphone/aux signals up to a usable level.
*   **Biasing:** I utilized a stable voltage-divider bias network with emitter degeneration resistors to ensure thermal stability and prevent Q-point drift.
*   **Isolation:** I implemented AC coupling capacitors (1 uF) between stages to block DC bias transmission.

### 2. Class-AB Power Amplifier Stage
*   **Transistors:** Complementary push-pull pair using TIP31A (NPN) and TIP32A (PNP), driven by a 2N3904 driver transistor.
*   **Function:** Provides high current gain to efficiently drive low-impedance loads like a loudspeaker.
*   **Biasing:** I implemented a diode-biasing network using 1N4148 diodes to provide a small quiescent current, effectively eliminating crossover distortion while keeping idle power consumption minimal.

---

## Experimental Results

I fully characterized the hardware prototype using a digital oscilloscope, function generator, and true RMS digital multimeters. Below are my measured performance parameters:

| Parameter | Measured Value | Unit / Note |
| :--- | :--- | :--- |
| Pre-amplifier Gain | 94 | Voltage Gain (Av) |
| Power Amplifier Gain | 2 | Voltage Gain (Av) |
| Overall Gain | 104 | Voltage Gain (Av) |
| Bandwidth | 20 kHz | -3 dB points: ~2 Hz to 20 kHz |
| Output Voltage Swing | 550 mV | Peak-to-peak (maximum undistorted) |
| Output Power | 5.97 W | Watts |
| Quiescent Current (IQ) | 40.1 mA | Confirms Class-AB alignment |
| THD @ 1 kHz | 0.92% | Total Harmonic Distortion |
| THD @ 500 Hz | 0.88% | Total Harmonic Distortion |
| Noise (RMS) | 2.787 mV | Millivolts RMS |
| PSRR | 18.3 dB | Power Supply Rejection Ratio |

---

## Key Findings and Performance Analysis

*   **Frequency Response:** My amplifier displays a remarkably flat mid-band gain from 50 Hz to 10 kHz. Roll-off characteristics at low frequencies are safely governed by the coupling capacitors, resulting in an overall high-fidelity audio bandwidth of 20 kHz.
*   **Linearity and Distortion:** The Total Harmonic Distortion (THD) remains strictly below 1% under typical small-signal conditions, validating the linear performance of my cascaded topology.
*   **Thermal Stability:** Small emitter degeneration resistors successfully mitigate the risk of thermal runaway in the push-pull output array.

---

## Hardware Components List
*   **Transistors:** BC547B, 2N3904, TIP31A, TIP32A
*   **Diodes:** 1N4148
*   **Capacitors:** 1 uF (Coupling), 1000 uF (Output DC-blocking)
*   **Resistors:** Various values (100 Ohms to 330 kOhms)
*   **Load:** 16 Ohm Loudspeaker / Resistive load dummy