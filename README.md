# 🌡️ STM32 Assembly Temperature Monitor

A bare-metal embedded system that reads temperature data using **pure Assembly Language** and visualizes it in real-time using Python.

![Project Graph](src/TEMP1.png) 
*(Add a screenshot of your Python plot here!)*

## 🚀 Project Overview
This project demonstrates low-level embedded engineering capabilities by implementing a complete Data Acquisition System without using any C/C++ HAL (Hardware Abstraction Libraries). 

The system reads an analog temperature sensor, processes the data via DMA, and transmits it via UART to a host computer where a Python script plots the data live.

## 🧠 Key Features
* **Bare-Metal Assembly:** 100% of the firmware is written in ARM Cortex-M4 Assembly.
* **DMA (Direct Memory Access):** uses DMA to transfer ADC data to memory and Memory to UART without CPU intervention.
* **Race Condition Handling:** Implements semaphore-based synchronization to prevent data corruption between ADC updates and UART transmission.
* **Real-Time Visualization:** Custom Python script (`plot_temp.py`) using `matplotlib` and `pyserial` to plot temperature data at 20Hz.
* **Hardware Timer Trigger:** Uses TIM2 to trigger ADC conversions at precise intervals (100Hz).

## 🛠️ Hardware & Software
* **Microcontroller:** STM32F446RE (Nucleo-64 Board)
* **Sensor:** Internal Temperature Sensor (or LM35)
* **Language:** ARM Assembly (`.s` files)
* **Host Software:** Python 3.9+ (Matplotlib, PySerial)
* **IDE:** STM32CubeIDE

## 🔌 Pin Connections
| Component | Nucleo Pin | Description |
|-----------|------------|-------------|
| TX Line   | PA2        | UART Transmit (USB VCP) |
| RX Line   | PA3        | UART Receive |
| Sensor    | Internal   | Connected to ADC1 Channel 0 |

## ⚙️ How to Run
### 1. Flash the Firmware
1.  Open the project in **STM32CubeIDE**.
2.  Build the project (Hammer icon).
3.  Connect the Nucleo board and hit **Run/Debug**.

### 2. Run the Python Plotter
Ensure you have Python installed, then set up the environment:

```bash
# Install dependencies
pip install -r requirements.txt

# Run the plotter
python plot_temp.py
