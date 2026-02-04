# FPGA Temperature Monitoring System with LTC2986

This project implements a temperature monitoring system on an FPGA platform
using the LTC2986 multi-sensor temperature measurement IC.
The FPGA communicates with the LTC2986 via SPI and transmits the measured
temperature data to an external display system via UART.

## Project Overview
The system demonstrates FPGA-based sensor interfacing and digital
communication. Temperature data is acquired from the LTC2986 through SPI,
processed on the FPGA, and sent over UART for real-time monitoring on an
external screen or terminal.

## System Architecture
- FPGA as the main processing unit
- LTC2986 temperature measurement IC
- SPI interface for sensor communication
- UART interface for data transmission to display/terminal

## Implementation Details
- Custom SPI master implementation on FPGA
- FSM-based control for LTC2986 configuration and data acquisition
- UART transmitter for serial data output
- Top-level module integrating SPI, UART, and control logic
- Fully synchronous HDL design

## Modules
- **SPI Module:** Handles communication between FPGA and LTC2986  
- **LTC2986 Controller:** Manages device configuration and temperature readout  
- **UART Module:** Transmits temperature data to an external display or terminal  
- **FSM Control:** Controls measurement and communication flow  
- **Top Module:** Integrates all system components

## Tools & Technologies
- FPGA development board
- LTC2986 temperature measurement IC
- VHDL / Verilog
- SPI protocol
- UART communication

## Purpose
This project was developed for educational and engineering practice purposes
to strengthen understanding of FPGA-based sensor interfacing and serial
communication protocols.
It is independent of any thesis or confidential research work.

## Key Learning Outcomes
- FPGA-based SPI communication with mixed-signal ICs
- UART-based data transmission and system integration
- Datasheet-driven hardware design
- Finite State Machine (FSM) based control architecture
- Modular and reusable HDL design

## Notes
The implementation is based on the LTC2986 datasheet and standard SPI/UART
protocol definitions. The project is intended as a portfolio demonstration
of FPGA, digital design, and communication interface skills.
