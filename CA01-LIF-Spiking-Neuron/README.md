# Hardware Implementation of Leaky Integrate-and-Fire (LIF) Spiking Neuron

## Project Overview
This project presents the Register-Transfer Level (RTL) architecture and SystemVerilog implementation of a **Leaky Integrate-and-Fire (LIF)** spiking neuron. It was developed as a core component for hardware-accelerated Spiking Neural Networks (SNNs) in the Computer Architecture course.

The design strictly adheres to resource-constrained hardware topologies, avoiding high-cost processing elements like multipliers by leveraging bitwise shift operations and a single shared Arithmetic Logic Unit (ALU).

## Mathematical Model & Discrete-Time Dynamics
The neuron membrane potential ($V$) and spike generation logic are governed by the following discrete-time Eulerian equations:

1. **Input Current Integration:**
   Accumulating the weighted contributions of pre-synaptic spikes from 8 connected neurons:
   $$I_k[n] = \sum_{j=0}^{n} W_{jk} S_j$$

2. **Membrane Potential Update:**
   Evaluating the leaky characteristic and the resting potential recovery where $\alpha = 0.25$:
   $$V[n+1] = V[n](1-\alpha) + \alpha V_{rest} + I[n]$$

3. **Fire & Reset Logic:**
   $$If \ V[n+1] \ge V_{th} \rightarrow V[n+1]=V_{rest}, \ S[n+1]=1$$

## Hardware Architecture & Constraints
The design is built upon an orthogonal **Datapath and Controller (FSMD)** architecture following the Huffman model:

* **Number System:** Computations are executed using a **12-bit signed fixed-point** format (`4.8` bit configuration: 4 integer bits, 8 fractional bits).
* **Resource Sharing (Single ALU):** To minimize power and silicon area, the entire calculation is serialized through a single, multi-purpose ALU capable of Addition, Subtraction, Right-Shift, and Comparison (`>=`).
* **Multiplier-Free Optimization:** The constant decay factor $\alpha = 0.25$ is implemented natively in hardware via two logical right arithmetic shifts (`>> 2`), entirely eliminating the need for bulky DSP multiplier blocks.
* **Synaptic Weight ROM:** The static synaptic weights ($w_1$ to $w_8$) are mapped into an $8 \times 12$-bit Read-Only Memory (ROM), instantiated and initialized via `$readmemb`.

## Verification Suite
The architecture is validated against a robust testbench feeding 20 sequential operational cycles. The verification monitors membrane potential accumulation, synchronous resetting upon threshold crossing ($V_{th}$), and correct spike emission ($S_{out}$) assertion.
