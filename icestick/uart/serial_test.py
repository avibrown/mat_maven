import serial
import time
import random 
# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0

string = "country"
string2 = "roads"
string3 = "take"
string4 = "me"
string5 = "home"
packetA = [b'\xFF',b'\x00',b'\x11',b'\x01',b'\x02',b'\x03',b'\x04']
packetB = [b'\xFF',b'\x01',b'\x11',b'\x05',b'\x06',b'\x07',b'\x08']
i = 0
try:
    while True:
        for byte in packetA:
            ser.write(byte)
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting))

        for byte in packetB:
            ser.write(byte)
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting))

        time.sleep(1)

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
