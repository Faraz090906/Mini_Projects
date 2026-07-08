# Arduino-Based Scientific Calculator

**Author:** Patnam Shariq Faraz Muhammed (EE24BTECH11049)

## Overview
This project is a functional, extendable, and highly optimized scientific calculator built on the Arduino platform. Designed specifically for the constrained memory environment of an AVR microcontroller, the software avoids external mathematical libraries. Instead, it parses complex expressions using the Shunting Yard algorithm and evaluates custom mathematical functions using the Runge-Kutta 4th Order (RK4) method and numerical approximations.

## Key Features
* **Expression Parsing:** Implements the Shunting Yard algorithm to convert infix mathematical expressions into Reverse Polish Notation (RPN), guaranteeing proper operator precedence and left-to-right evaluation.
* **RK4 Mathematical Evaluation:** Core functions are solved through differential equations rather than series expansions, offering precision and optimized performance. Supported functions include:
    * Trigonometric and Inverse Trigonometric: sin(x), cos(x), tan(x), arcsin(x), arccos(x), and arctan(x).
    * Exponential and Logarithmic: pow(x,w) and ln(x).
* **Hyperbolic & Utility Functions:** Includes hyperbolic functions (sinh(x), cosh(x), tanh(x)), decimal-to-fraction conversions (using GCD), factorials, and the famous Quake III algorithm for fast inverse square roots.
* **Advanced User Interface:** Features a 6x6 matrix keypad with hardware debouncing mechanisms, supporting both Standard and Advanced mode mappings. 
* **Robust Memory Management:** Utilizes EEPROM for persistent memory storage and recall, alongside fixed-size statically allocated arrays to minimize dynamic memory usage.

---

## Hardware Requirements
To build this project, you will need the following components:
* Arduino UNO
* 16x2 LCD Display
* 36 Push Buttons (for the 6x6 matrix)
* Potentiometer
* Breadboard and Jumper Wires
* Cell phone (utilized as a power source for the Arduino)

---

## Pin Connections 

**LCD Display Connection Map**
| Signal / Pin Name | Arduino Connection |
| :--- | :--- |
| LCD E (Enable) | PB1 |
| DB4 | Pin 2 |
| DB5 | Pin 3 |
| DB6 | Pin 4 |
| DB7 | Pin 5 |

**Push Button Matrix Connection Map**
| Signal / Pin Name | Arduino Connection |
| :--- | :--- |
| ROW Signals | PORTC |
| COLUMN Signals | PORTD |

---

## Software Architecture
The calculator's software is divided into three primary components:
1.  **Expression Parsing and Evaluation System:** Uses a custom `Token` structure to identify numbers, operators, and functions. It converts the token stream to RPN and evaluates it using a stack-based approach.
2.  **User Interface and Input Handling:** Handles mode switching and uses sequential ROW/COLUMN scanning with a delay-based debounce function to register stable key presses. It also manages a 16x2 character display with multi-line scrolling capabilities.
3.  **Hardware Interaction Layer:** Focuses on direct hardware register manipulation for minimal computational overhead, employing state machine, interpreter, and command design patterns.

---

## Future Improvements
Potential future enhancements for this firmware include:
* Implementing advanced error handling for complex or invalid expressions.
* Expanding the mathematical function library.
* Enhancing floating-point precision handling.