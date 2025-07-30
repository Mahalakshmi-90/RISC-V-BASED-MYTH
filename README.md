RISC-V-BASED-MYTH Workshop Report

Overview 

The RISC-V based MYTH (Microprocessor for You in Thirty Hours) workshop, organized by VSD and Redwood EDA, is a comprehensive five-day program designed to provide participants with a hands-on introduction to the RISC-V Instruction Set Architecture (ISA) and microprocessor design. This workshop, attended by Ahtesham Ahmed, an 8th-grade student, covers the journey from software to hardware, guiding participants through C programming, assembly, digital logic, and the design of a pipelined RISC-V CPU. The following report summarizes the key learnings, labs, and outcomes of the workshop, as documented in the GitHub repository RISCV_MYTH. Workshop Structure The workshop is divided into five days, each focusing on a specific aspect of RISC-V architecture and microprocessor design. Participants progress from foundational concepts to advanced topics, with practical labs reinforcing theoretical knowledge. Below is a detailed breakdown of each day’s content and activities.

Day 1: Introduction to RISC-V ISA and GNU Compiler Toolchain Focus: Understanding the RISC-V ISA, binary number systems, and the GNU compiler toolchain.

Key Concepts:

RISC-V ISA: An open-source instruction set architecture that provides a modular and extensible framework for processor design, applicable in embedded systems and high-performance computing. Binary Number System: Introduction to binary numbers (0s and 1s), bits, bytes, words, and doublewords. The number of possible combinations for an n-bit binary number is calculated as (2^n). Signed and Unsigned Numbers: Unsigned numbers represent non-negative integers, while signed numbers use the most significant bit (MSB) to indicate positivity (0) or negativity (1). GNU Compiler Toolchain: Tools like GCC and Spike simulator for compiling and running RISC-V programs.

Labs:
Wrote and compiled a C program (1ton.c) to calculate the sum of numbers from 1 to n using GCC (gcc 1ton.c) and executed it (./a.out). Simulated the same program using the RISC-V GCC toolchain (riscv64-unknown-elf-gcc) and Spike simulator (spike pk 1ton.o), verifying identical outputs.

Day 2: Introduction to ABI and Basic Verification Flow Focus: Exploring the Application Binary Interface (ABI) and basic verification processes.

Key Concepts:

ABI: Defines the interface between compiled applications and the operating system, ensuring compatibility between binary modules. It standardizes how compilers and assemblers generate binary code. RISC-V Registers: The RISC-V architecture uses 32 registers, each represented by a 5-bit binary pattern ((2^5 = 32)), as seen in instructions like load doubleword.

Labs:

Implemented a 1-to-9 adder using ABI by creating two files: 1to9_custom.c (C program) and load.S (assembly code for the summation logic). Compiled both files using riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o 1to9_custom.o 1to9_custom.c load.S and simulated with spike pk 1to9_custom.o, confirming correct summation output.



Day 3: Digital Logic with TL-Verilog and Makerchip Focus: Introduction to digital logic, combinational and sequential circuits, and TL-Verilog on the Makerchip platform.

Key Concepts:

Logic Gates: Fundamental gates (AND, OR, NOT) form the basis of digital circuits, enabling the creation of complex gates like NAND, NOR, XOR, and XNOR. Combinational Circuits: Outputs depend only on current inputs, with no memory of past states. Sequential Circuits: Outputs depend on current inputs and past states, using memory elements like flip-flops. Flip-Flops: Bistable devices that store a single bit, toggled by control signals like clock pulses. Pipelined Logic: Divides tasks into stages for parallel execution, improving throughput. Validity: Optimizes chip design by eliminating idle gates, reducing power consumption.

Labs:

Combinational Calculator: Implemented a TL-Verilog calculator for addition, subtraction, multiplication, and division in Makerchip. Sequential Calculator: Extended the combinational calculator to include sequential logic. Fibonacci Sequence: Designed a TL-Verilog circuit to generate the Fibonacci sequence, where each value is the sum of the previous two. Pythagorean Theorem Pipeline: Created a pipelined circuit to compute (c = \sqrt{a^2 + b^2}). Calculator with Validity and Memory: Enhanced the calculator with validity checks and memory operations.

Day 4: Basic RISC-V CPU Microarchitecture Focus: Building the foundational components of a RISC-V CPU microarchitecture.

Key Concepts:

Program Counter (PC) Multiplexer: Selects the next instruction address based on instruction type. Instruction Memory (IMEM) Read: Fetches instructions from memory using the PC address. Decoder: Translates binary instructions into control signals for execution. Register File: Manages 32 registers for read and write operations. Arithmetic Logic Unit (ALU): Performs arithmetic and logical operations.

Labs:

Fetch and Decode: Implemented TL-Verilog code for instruction fetch and decoding, covering instruction types (I, R, S, B, J, U) and immediate value extraction. Half-Completed RISC-V CPU: Built a partial CPU to perform addition


Day 5: Complete Pipelined RISC-V CPU Microarchitecture Focus: Completing a pipelined RISC-V CPU with full functionality.

Key Concepts:

Pipelining: Divides the CPU into stages (fetch, decode, execute, memory, write-back) for parallel instruction processing. Branch and Jump Handling: Manages control flow with instructions like BEQ, BNE, JAL, and JALR. Memory Operations: Supports load and store instructions for data memory access. Verification: Ensures the CPU correctly computes the sum of numbers 1 to 9.

Labs:

Implemented a complete pipelined RISC-V CPU in TL-Verilog, incorporating instruction fetch, decode, register file operations, ALU, branch/jump handling, and memory operations. Verified the CPU by checking if register x10 contains the sum (1+2+3+4+5+6+7+8+9 = 45).

Tools and Platforms

Linux Terminal: 
Used for compiling and running C and assembly programs. Spike Simulator: Simulated RISC-V programs to verify functionality. Makerchip IDE: Provided a platform for writing, compiling, and visualizing TL-Verilog code. RISC-V GCC Toolchain: Compiled C and assembly code for the RISC-V architecture.

Outcomes:
The workshop equipped participants with a deep understanding of RISC-V architecture and microprocessor design. Key outcomes include:

Proficiency in writing and simulating C and assembly programs for RISC-V. Practical experience in designing combinational and sequential circuits using TL-Verilog. Successful implementation of a pipelined RISC-V CPU capable of executing arithmetic, logical, branch, jump, and memory operations. Enhanced problem-solving skills through hands-on labs and debugging.

Acknowledgements Special thanks to Kunal Ghosh for guiding the first two days and Steve Hoover for teaching the final three days. Gratitude is extended to VSD and Redwood EDA for organizing this educational workshop, making complex concepts accessible to young learners like Ahtesham Ahmed.

Conclusion:
The RISC-V based MYTH workshop is an excellent platform for learning microprocessor design, from foundational concepts to advanced CPU implementation. Through structured lessons and hands-on labs, participants gain practical skills in RISC-V programming, digital logic, and microarchitecture design. This workshop is highly recommended for students and enthusiasts interested in computer architecture and hardware design.
