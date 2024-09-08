import serial
import time
import random 
# Configure the serial port
ser = serial.Serial('/dev/ttyUSB0', 115200)
flag = 0

packetA = [b'\xFF',b'\x00',b'\x11',b'\x01',b'\x02',b'\x03',b'\x04']
packetB = b'\xFF\x01\x11\x05\x06\x07\x08'
# packetA = b'\xFF\x00\x11'
# packetB = b'\xFF\x01\x11'
test = b'\xDE\xAD\xBE\xEF'

chars = "hello world"
i = 0
try:
    while True:
        for byte in packetA:
            ser.write(byte)
            time.sleep(0.01)
        # ser.write(packetA)
        # time.sleep(0.1)
        # ser.write(packetB)
        # time.sleep(0.1)
        if ser.in_waiting > 0:
            print("rx from fpga: ", ser.read(ser.in_waiting))
            # incoming_bytes = ser.read(ser.in_waiting)
            # [print(hex(byte), end=' ') for byte in incoming_bytes]
            # print()

        # # # Prompt for user input
        # # message = input("Enter message to send: ")
        # time.sleep(0.1)
        


        # print(f"Sent: {message}")
        # time.sleep(1)
        time.sleep(1)

except KeyboardInterrupt:
    print("\nExiting...")
finally:
    # Ensure the serial port is closed on exit
    ser.close()
