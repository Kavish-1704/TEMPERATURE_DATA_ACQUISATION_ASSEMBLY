# 🌡️ STM32 Assembly Temperature Monitor

A bare-metal embedded system that reads temperature data using **pure Assembly Language** and visualizes it in real-time using Python.

![Project Graph(1)](Src/TEMP1.png) 
![Project Graph)2)](Src/TEMP2.png) 


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
* **Sensor:** Internal Temperature Sensor
* **Language:** ARM Assembly
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




## 📦 Install Dependencies

To run the real-time visualization tool (`plot_temp.py`), you need Python 3 installed.

### 1. Set up a Virtual Environment (Recommended)
It is best practice to run this project in a virtual environment to avoid conflicts.

**On macOS / Linux:**
```bash
python3 -m venv stm32_env
source stm32_env/bin/activate
```




## 📂 Project Structure

* **`Src/main.s`**: The entry point. Handles the main infinite loop, coordinates the synchronization between CPU and DMA, and triggers data transmission.
* **`Src/DMA.s`**: Configures Direct Memory Access (DMA2 for ADC, DMA1 for UART) to handle data transfer without CPU intervention.
* **`Src/ADC.s`**: Sets up the Analog-to-Digital Converter to read the internal temperature sensor.
* **`Src/lab_uart.s`**: Low-level UART driver to handle serial communication with the host computer.
* **`Src/Tim2.s`**: Configures hardware Timer 2 to trigger ADC conversions at a precise 100Hz frequency.
* **`Src/Itoa.s`**: Custom assembly routine to convert raw Integer values into ASCII strings.
* **`plot_temp.py`**: Python script using `matplotlib` to visualize the temperature data in real-time.
* **`requirements.txt`**: List of Python dependencies.


## 🐛 Challenges Solved
* **Race Condition (Data Corruption):** Initially, the system outputted glitchy values (e.g., "1121" instead of "23") because the CPU was updating the buffer while the UART DMA was still reading it. 
    * *Solution:* Implemented a "Busy Flag" check (Semaphore) to force the CPU to wait until the previous UART transmission is complete before touching the buffer.
* **DMA Bus Faults:** Encountered hard faults when writing to DMA control registers.
    * *Solution:* Implemented a "Wait for Disable" subroutine to ensure the DMA stream is fully disabled and the hardware is ready before attempting reconfiguration.
* **IDE & Console Crashes:** The UART was initially transmitting data too rapidly, overflowing the buffer and crashing the IDE.
    * *Solution:* Optimized the main loop timing and added appropriate delays to stabilize the data stream.
* **Cross-Platform Visualization:**
    * *Solution:* Created a robust Python script that auto-detects the specific STM32 USB port on macOS/Linux and handles real-time plotting via a Virtual Environment.

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
python plot_temp.py

