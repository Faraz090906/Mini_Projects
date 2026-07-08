# AVR ATmega328P Digital Clock with Time Zone Support

This repository contains the full embedded C source code, compilation configuration, and technical documentation for the digital clock system I designed and implemented using an AVR ATmega328P microcontroller (Arduino Uno board). The system maintains accurate real-time tracking using internal hardware timers without requiring an external Real-Time Clock (RTC) module.

## Author
* Patnam Shariq Faraz Muhammed (EE24BTECH11049)

---

## Objective
The goal of my project was to build an efficient, standalone digital clock capable of displaying real-time clock tracking simultaneously on two distinct output mediums: a character-based 16x2 LCD and a multiplexed 6-digit 7-segment display. The implementation features an interactive UI that allows the user to manually configure the initial Indian Standard Time (IST) on boot and dynamically cycle through multiple predefined global time zones using tactile push-buttons.

---

## Hardware Features and Component Details
* **Microcontroller:** ATmega328P (running at a clock frequency of 16 MHz).
* **Dual-Display Interface:** * 16x2 Character LCD (HD44780 compliant) operating in 4-bit parallel data mode.
    * 6-Digit 7-Segment Display array for hours (HH), minutes (MM), and seconds (SS).
* **Decoder IC:** 7447 BCD-to-7-Segment Decoder used to minimize the digital output pins required to drive the segments.
* **User Controls:** Two active-low tactile push buttons configured with internal pull-up resistors for menu navigation (Toggle and Select).

---

## Pin Configurations and Layout Mapping

### 1. LCD Module Connection
* **RS (Register Select):** PB0
* **E (Enable):** PB1
* **D4 - D7 (Data Lines):** PB2, PB3, PB4, PB5

### 2. User Interface Buttons
* **Toggle Button:** PD2 (External Interrupt Pin / Pin Change pin used as standard input)
* **Select Button:** PD3

### 3. Seven-Segment Multiplexing Control
* **BCD Output Lines (A, B, C, D to 7447):** PD4, PD5, PD6, PD7
* **Common Anode/Cathode Digit Selectors (Multiplexing Enables):**
    * Hours (Tens / Ones): PC0 / PC1
    * Minutes (Tens / Ones): PC2 / PC3
    * Seconds (Tens / Ones): PC4 / PC5

---

## Core Software Architecture

The firmware is written completely in low-level AVR C code utilizing direct register manipulation to maximize code compactness and execution efficiency.

### 1. Timekeeping via Timer1
I configured the internal 16-bit Timer1 to run in Clear Timer on Compare Match (CTC) mode. Using an exact compare value matching constraint along with a prescaler, Timer1 triggers an Interrupt Service Routine (`ISR(TIMER1_COMPA_vect)`) exactly once every second. This background process updates the primary clock registers (`seconds`, `minutes`, and `hours`) deterministically.

### 2. Display Multiplexing via Timer0
To drive 6 numeric digits without consuming 42 separate I/O paths, I implemented a multiplexing sweep using the 8-bit Timer0. It triggers an interrupt every few milliseconds (`ISR(TIMER0_COMPA_vect)`). During each pass, the routine deasserts the previous digit line on `PORTC`, writes the new BCD values for the active target digit to `PORTD`, and activates the corresponding common line selector to create a flicker-free perspective persistence.

### 3. Dynamic Timezone Conversions
The clock maintains a foundational baseline time counter. When a user updates the active location profile, the program applies a relative integer offset to evaluate the adjusted localized reading. Supported configurations include:
* Indian Standard Time (IST)
* UTC-5, UTC-10, UTC+3, UTC+4, UTC+9, UTC-7, UTC+1

---

## Compilation and Deployment Workflow

The project contains a standard build orchestration script via a custom `Makefile`. 

### Prerequisites
Make sure your development machine has the standard GCC compiler toolchain for AVR architectures installed:
```bash
sudo apt-get install gcc-avr binutils-avr avr-libc avrdude