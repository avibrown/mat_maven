import serial
import time
import random 
# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0

packetA = [b'\xFF',b'\x00',b'\x11',b'\x01',b'\x02',b'\x03',b'\x04']
string = "country"
string2 = "roads"
string3 = "take"
string4 = "me"
string5 = "home"
packetB = b'\xFF\x01\x11\x05\x06\x07\x08'
# packetA = b'\xFF\x00\x11'
# packetB = b'\xFF\x01\x11'
test = b'\xDE\xAD\xBE\xEF'

chars = "hello world"
i = 0
try:
    while True:
        for byte in string:
            ser.write(byte.encode('utf-8'))
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting).decode('utf-8'))

        for byte in string2:
            ser.write(byte.encode('utf-8'))
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting).decode('utf-8'))

        for byte in string3:
            ser.write(byte.encode('utf-8'))
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting).decode('utf-8'))

        for byte in string4:
            ser.write(byte.encode('utf-8'))
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting).decode('utf-8'))

        for byte in string5:
            ser.write(byte.encode('utf-8'))
        time.sleep(0.01)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting).decode('utf-8'))

        time.sleep(1)

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
