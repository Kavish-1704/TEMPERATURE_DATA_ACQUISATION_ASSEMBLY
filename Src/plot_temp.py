import serial
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from collections import deque
import glob
import sys

# ==========================================
# STM32 REAL-TIME PLOTTER
# Run with: python plot_temp.py
# Requires: pip install pyserial matplotlib
# ==========================================

# --- AUTO-DETECT PORT (Mac/Linux) ---
def get_mac_port():
    # Look for the nucleo modem port
    ports = glob.glob('/dev/tty.usbmodem*')
    if ports:
        return ports[0]
    return None

# --- CONFIGURATION ---
SERIAL_PORT = get_mac_port()
BAUD_RATE = 9600
MAX_POINTS = 100

print(f"--- STM32 Temperature Monitor ---")

if not SERIAL_PORT:
    print("❌ Error: No STM32 board found!")
    print("   Please check the USB cable.")
    sys.exit()

print(f"✅ Found board at: {SERIAL_PORT}")
print("   Press Ctrl+C to stop.")

# --- CONNECT TO UART ---
try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    ser.reset_input_buffer()
except serial.SerialException as e:
    print(f"❌ Error opening port: {e}")
    sys.exit()

# --- SETUP PLOT ---
x_data = deque(maxlen=MAX_POINTS)
y_data = deque(maxlen=MAX_POINTS)

fig, ax = plt.subplots()
line, = ax.plot([], [], 'r-', linewidth=2)  # Red line

ax.set_ylim(0, 50) # Fixed scale 0-50C
ax.set_title("STM32 Real-Time Temperature")
ax.set_ylabel("Celsius (°C)")
ax.set_xlabel("Time (Samples)")
ax.grid(True)

def init():
    line.set_data([], [])
    return line,

def update(frame):
    if ser.in_waiting:
        try:
            # Read line, decode, remove whitespace
            line_data = ser.readline().decode('utf-8', errors='ignore').strip()
            
            # Check if it's a valid integer
            if line_data.isdigit():
                val = int(line_data)
                
                # Filter out obvious glitches
                if 0 <= val <= 100:
                    y_data.append(val)
                    x_data.append(len(x_data))
                    
                    line.set_data(range(len(y_data)), y_data)
                    ax.set_xlim(0, max(len(y_data), 10))
                    print(f"Reading: {val}°C")
        except ValueError:
            pass 
            
    return line,

ani = animation.FuncAnimation(fig, update, init_func=init, interval=50, blit=True)
plt.show()

ser.close()