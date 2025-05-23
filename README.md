# Muon-Detector
Muon Detector Simulation (FPGA-based)
A simulation of a muon detection system using Verilog, designed to identify coincident events (muons) using FIFO buffers and coincidence logic. Built and tested via testbenches, aimed at real-world implementation on FPGA hardware.

 Features :
1) FIFO-based buffering for input signals
2) Coincidence detection logic for event validation
3) Verilog testbench for simulation and functional verification
4) Modular, synthesizable HDL design


Tech Stack:
Language: Verilog HDL
Simulation Tool: ModelSim

Simulation:
All modules were tested using Verilog testbenches.
Output waveform analysis via GTK wave.

Future Improvements : 
Connect to FPGA board and simulate detector hits using push-buttons
Implement output via LEDs, 7-segment displays, or UART logging
Add actual sensor integration and real-world signal conditioning

 
