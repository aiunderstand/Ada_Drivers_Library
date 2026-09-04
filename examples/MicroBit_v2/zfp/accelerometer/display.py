import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import serial
import argparse
import re

def read_serial_data(ser):
    line = ser.readline().decode('utf-8').strip()
    return line

def parse_arrow_data(data_str):
    # match = re.match(r'X:\s*(-?\d+\.?\d*)\s+Y:\s*(-?\d+\.?\d*)\s+Z:\s*(-?\d+\.?\d*)', data_str)
    match = re.match(r'ACC;X,\s*(-?\d+\.?\d*);Y,\s*(-?\d+\.?\d*);Z,\s*(-?\d+\.?\d*)', data_str)
    if match:
        x = float(match.group(1))
        y = float(match.group(2))
        z = float(match.group(3))
        return np.array([x, y, z])
    else:
        raise ValueError("String does not match pattern 'ACC;X,value;Y,value;Z,value'"+data_str)

def update_arrow(ax, arrow, new_data):
    arrow.remove()
    arrow = ax.quiver(0, 0, 0, new_data[0], new_data[1], new_data[2], color='r')
    plt.draw()
    return arrow

def main():
    parser = argparse.ArgumentParser(description='Display micro:bit orientation as a 3D arrow using accelerometer data.')
    parser.add_argument('--port', type=str, required=True, help='Serial port device filename')
    parser.add_argument('--baudrate', type=int, default=9600, help='Baudrate for the serial port')
    args = parser.parse_args()

    ser = serial.Serial(args.port, args.baudrate)

    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    ax.set_xlim([-1, 1])
    ax.set_ylim([-1, 1])
    ax.set_zlim([-1, 1])

    # Initial arrow
    arrow = ax.quiver(0, 0, 0, 1, 0, 0, color='r')

    plt.ion()
    plt.show()

    try:
        while True:
            # Read data from serial port
            data_str = read_serial_data(ser)
            print(data_str)
            new_data = parse_arrow_data(data_str)
            new_data = new_data/255.0
            print(new_data)
            arrow = update_arrow(ax, arrow, new_data)
            plt.pause(0.01)
    except KeyboardInterrupt:
        ser.close()

if __name__ == "__main__":
    main()
